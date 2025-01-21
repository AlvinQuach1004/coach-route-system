module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy]
    def index # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      authorize(User)
      @users = User.all

      # Apply search filter if search parameter is present
      if params[:search].present?
        @users = @users.where(
          'email ILIKE :search',
          search: "%#{params[:search]}%"
        )
      end

      if params[:role].present? && ['customer', 'admin'].include?(params[:role].downcase)
        @users = @users.with_role(params[:role])
      end

      # Apply sorting
      @users = case params[:sort_by]&.downcase
               when 'oldest'
                 @users.order(created_at: :asc)
               when 'email_asc'
                 @users.order(email: :asc)
               when 'email_desc'
                 @users.order(email: :desc)
               else
                 @users.order(created_at: :desc) # Default to newest
               end

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
        redirect_to admin_users_path
        flash[:success] = 'User was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if update_user_with_roles
        redirect_to admin_users_path
        flash[:success] = 'User was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == current_user
        redirect_to admin_users_path
        flash[:warning] = 'You cannot delete your own account.'
        return
      end
      @user.destroy!
      redirect_to admin_users_path
      flash[:success] = 'User was successfully deleted.'
    end

    private

    def set_user
      @user = User.find(params[:id])
      authorize(@user)
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_users_path, alert: 'User not found.'
    end

    def user_params
      permitted = params.require(:user).permit(:email, :phone_number, :password, :password_confirmation, :role)

      # Handle password params
      if permitted[:password].blank?
        permitted.except(:password, :password_confirmation)
      else
        permitted
      end
    end

    def update_user_roles
      return if params[:user][:role].blank?

      role = params[:user][:role].downcase
      @user.roles = []
      @user.add_role(role)
    rescue StandardError
      @user.errors.add(:role, 'Error updating role')
      raise
    end

    def update_user_with_roles
      ActiveRecord::Base.transaction do
        # Update basic attributes
        user_attributes = user_params.except(:role)
        success = @user.update!(user_attributes)

        # Update roles if basic update succeeds
        if success
          update_user_roles
        end

        success
      end
    rescue StandardError
      @user.errors.add(:base, 'Error updating user')
      false
    end
  end
end
