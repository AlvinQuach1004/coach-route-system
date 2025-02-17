class ProfilesController < ApplicationController
  before_action :authenticate_user!
  layout :choose_layout

  def show
  rescue StandardError => e
    Sentry.capture_exception(e)
    flash[:error] = 'There was an error loading your profile. Please try again.'
    redirect_to root_path
  end

  def update_field # rubocop:disable Metrics/MethodLength
    field = user_params.keys.first
    if current_user.update(user_params)
      flash.now[:success] = t('profile.update_success', field: t("profile.#{field}"))

      render json: {
        success: true,
        html: render_to_string(
          partial: 'layouts/flash',
          locals: { message: flash[:success], type: 'success' },
          formats: [:html]
        ),
        new_value: current_user.send(field)
      }
    else
      error_message = t('profile.update_error', field: t("profile.#{field}"))

      render json: {
               success: false,
               html: render_to_string(
                 partial: 'layouts/flash',
                 locals: { message: error_message, type: 'error' },
                 formats: [:html]
               )
             },
        status: :unprocessable_entity
    end
  rescue StandardError => e
    Sentry.capture_exception(e)
    flash[:alert] = 'There was an error updating your profile. Please try again.'
    render json: {
             success: false,
             html: render_to_string(
               partial: 'layouts/flash',
               locals: { message: flash[:error], type: 'error' },
               formats: [:html]
             )
           },
      status: :unprocessable_entity
  end

  private

  def choose_layout
    current_user.admin? ? 'admin' : 'application'
  end

  def user_params
    params.require(:user).permit(:email, :phone_number)
  end
end
