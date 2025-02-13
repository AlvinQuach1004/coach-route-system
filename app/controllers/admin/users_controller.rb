module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy]

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

      process_user_save(:new, 'User was successfully created.')
    end

    def update
      process_user_update('User was successfully updated.', :edit)
    end

    def destroy
      if prevent_self_deletion
        redirect_to admin_users_path and return
      end

      flash[(@user.destroy ? :success : :error)] = @user.destroy ? 'User was successfully deleted.' : 'Failed to delete the user.'
      redirect_to admin_users_path
    end

    private

    def set_user
      @user = User.find(params[:id])
      authorize(@user)
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_users_path, alert: 'User not found.'
    end

    def user_params
      params.require(:user).permit(:email, :phone_number, :password, :password_confirmation, :role).tap do |permitted|
        permitted.delete(:password)
        permitted.delete(:password_confirmation) if permitted[:password].blank?
      end
    end

    def update_user_roles
      return if params[:user][:role].blank?

      @user.roles = []
      @user.add_role(params[:user][:role].downcase)
    rescue StandardError => e
      @user.errors.add(:role, "Error updating role: #{e.message}")
      raise ActiveRecord::Rollback
    end

    def update_user_with_roles
      ActiveRecord::Base.transaction do
        @user.update!(user_params.except(:role))
        update_user_roles
      end
    rescue StandardError => e
      @user.errors.add(:base, "Error updating user: #{e.message}")
      false
    end

    def process_user_save(failure_action, success_message)
      if @user.save
        update_user_roles
        flash[:success] = success_message
        redirect_to admin_users_path
      else
        handle_failure(failure_action)
      end
    end

    def process_user_update(success_message, failure_action)
      if update_user_with_roles
        flash[:success] = success_message
        redirect_to admin_users_path
      else
        handle_failure(failure_action)
      end
    end

    def prevent_self_deletion
      if @user == current_user
        flash[:alert] = 'You cannot delete your own account.'
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
      render action, status: :unprocessable_entity
    end
  end
end
