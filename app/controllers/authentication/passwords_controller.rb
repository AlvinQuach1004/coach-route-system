module Authentication
  class PasswordsController < Devise::PasswordsController
    def update # rubocop:disable Metrics/AbcSize
      self.resource = resource_class.reset_password_by_token(resource_params)
      yield resource if block_given?
      if resource.errors.any?
        Rails.logger.error("Reset password failed: #{resource.errors.full_messages}")
      end
      if resource.errors.empty?
        resource.unlock_access! if unlockable?(resource)
        resource.after_password_reset if resource.respond_to?(:after_password_reset)
        flash[:notice] = I18n.t('devise.passwords.updated_not_active') if resource.active_for_authentication?
        redirect_to after_resetting_password_path_for(resource)
      else
        respond_with resource
      end
    end
  end
end
