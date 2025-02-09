module Authentication
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, only: [:google_oauth2]

    def google_oauth2
      user = User.from_google(from_google_params)

      if user.present?
        flash[:success] = t('devise.omniauth_callbacks.success', kind: 'Google')
        sign_in_and_redirect user, event: :authentication
      else
        flash[:alert] = t(
          'devise.omniauth_callbacks.failure',
          kind: 'Google',
          reason: "#{auth.info.email} does not belong to the organization"
        )
        redirect_to new_user_session_path
      end
    end

    def from_google_params
      @from_google_params ||= {
        uid: auth.uid,
        email: auth.info.email
      }
    end

    def auth
      @auth ||= request.env['omniauth.auth']
    end
  end
end
