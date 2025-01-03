module Authentication
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_permitted_parameters
    after_action :assign_role

    protected

    def assign_role
      if User.count.zero?
        resource.add_role(:admin)
      else
        resource.add_role(:customer)
      end
    end

    def after_update_path_for(_resource)
      sign_in_after_change_password? ? edit_user_registration_path : new_session_path(resource_name)
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:account_update, keys: [:avatar, :phone_number])
      devise_parameter_sanitizer.permit(:sign_up, keys: [:phone_number])
    end

    def update_resource(resource, params)
      params.compact_blank!
      resource.send(params.keys == ['avatar'] ? :update : :update_with_password, params)
    end
  end
end
