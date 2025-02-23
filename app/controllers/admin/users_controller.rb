module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy]
    before_action :prevent_self_deletion, only: [:destroy]

    def index
      authorize(User)
      @users = filtered_users
      @total_users = @users.size
      @pagy, @users = pagy(@users, page: params[:page])

      respond_with_users
    end

    def show; end

    def new
      @user = User.new
      authorize(@user)
    end

    def edit; end

    def create
      @user = User.new(user_params)
      authorize(@user)

      process_user_save(:new, t('.success'))
    end

    def update
      process_user_update(t('.success'), :edit)
    end

    def destroy
      if prevent_self_deletion
        redirect_to admin_users_path and return
      end

      flash[(@user.destroy ? :success : :alert)] = @user.destroy ? t('.success') : t('.failure')
      redirect_to admin_users_path
    end

    private

    def set_user
      @user = User.find(params[:id])
      authorize(@user)
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_users_path, alert: t('admin.users.errors.not_found')
    end

    def user_params
      params.require(:user).permit(:email, :phone_number, :password, :password_confirmation, :role).tap do |permitted|
        permitted.delete(:password)
        permitted.delete(:password_confirmation) if permitted[:password].blank?
      end
    end

    def update_user_with_roles
      ActiveRecord::Base.transaction do
        if @user.update(user_params.except(:role))
          update_user_roles
          true
        else
          false
        end
      end
    rescue StandardError => e
      @user.errors.add(:base, "Error updating user: #{e.message}")
      false
    end

    def update_user_roles
      return true if params[:user][:role].blank?

      @user.roles.destroy_all
      @user.add_role(params[:user][:role].downcase)
      true
    rescue StandardError => e
      Sentry.capture_exception(e)
      @user.errors.add(:role, "Error updating role: #{e.message}")
      raise ActiveRecord::Rollback
    end

    def process_user_update(success_message, failure_action)
      if update_user_with_roles
        flash[:success] = success_message

        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace('toast_flash', partial: 'layouts/flash'),
              turbo_stream.remove('modal_users'),
              turbo_stream.replace('users_table', partial: 'admin/users/shared/users', locals: { users: @users })
            ]
          end
          format.html { redirect_to admin_users_path }
        end
      else
        handle_failure(failure_action)
      end
    end

    def prevent_self_deletion
      if @user == current_user
        flash[:alert] = t('admin.users.destroy.self_deletion')
        true
      else
        false
      end
    end

    def filtered_users
      User.search(params[:search])
        .role_filter(params[:role])
        .sort_by_param(params[:sort_by])
    end

    def respond_with_users
      respond_to do |format|
        format.html
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'users_table',
            partial: 'admin/users/shared/users',
            locals: { users: @users }
          )
        end
      end
    end

    def handle_failure(action)
      flash.now[:warning] = @user.errors.full_messages.to_sentence.presence || 'An error occurred. Please try again.'

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('toast_flash', partial: 'layouts/flash')
        end
        format.html { render action, status: :unprocessable_entity }
      end
    end
  end
end
