module Authentication
  class SessionsController < Devise::SessionsController
    def create
      user = User.find_by(email: params[:user][:email])
      if user.nil?
        flash[:alert] = I18n.t('devise.failure.invalid_email')
      elsif !user.valid_password?(params[:user][:password])
        flash[:alert] = I18n.t('devise.failure.invalid_password')
      else
        super
        return
      end
      redirect_to new_session_path(resource_name)
    end

    protected

    def after_sign_in_path_for(resource)
      return admin_root_path if resource.admin?
      return customer_root_path if resource.customer?

      stored_location_for(resource) || root_path
    end
  end
end
