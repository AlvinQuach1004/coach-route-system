module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy]

    def index
      authorize(User)
      @users = User.search(params[:search])
        .role_filter(params[:role])
        .sort_by_param(params[:sort_by])
        .all
      @total_users = @users.size
      @pagy, @users = pagy(@users, page: params[:page])

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

    def show; end

    def new
      @user = User.new
      authorize(@user)
    end

    def edit; end

    def create
      @user = User.new(user_params)
      authorize(@user)

      if @user.save
        update_user_roles
        flash[:success] = 'User was successfully created.'
        redirect_to admin_users_path
      else
        handle_failure(:new)
      end
    end

    def update
      if update_user_with_roles
        flash[:success] = 'User was successfully updated.'
        redirect_to admin_users_path
      else
        handle_failure(:edit)
      end
    end

    def destroy
      if @user == current_user
        flash[:warning] = 'You cannot delete your own account.'
        redirect_to admin_users_path
        return
      end

      if @user.destroy
        flash[:success] = 'User was successfully deleted.'
      else
        flash[:error] = 'Failed to delete the user.'
      end

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
        if permitted[:password].blank?
          permitted.except!(:password, :password_confirmation)
        end
      end
    end

    def update_user_roles
      return if params[:user][:role].blank?

      role = params[:user][:role].downcase
      @user.roles = []
      @user.add_role(role)
    rescue StandardError => e
      @user.errors.add(:role, "Error updating role: #{e.message}")
      raise ActiveRecord::Rollback
    end

    def update_user_with_roles
      ActiveRecord::Base.transaction do
        @user.update!(user_params.except(:role)) && update_user_roles
      end
    rescue StandardError => e
      @user.errors.add(:base, "Error updating user: #{e.message}")
      false
    end

    def handle_failure(action)
      flash.now[:warning] = @user.errors.full_messages.to_sentence.presence || 'An error occurred. Please try again.'
      render action, status: :unprocessable_entity
    end
  end
end
