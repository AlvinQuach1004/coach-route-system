class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show; end

  def update_field
    if current_user.update(user_params)
      flash.now[:success] = "#{user_params.keys.first.humanize} updated successfully"

      render json: {
        success: true,
        html: render_to_string(
          partial: 'layouts/flash',
          locals: { message: flash[:success], type: 'success' },
          formats: [:html]
        ),
        new_value: current_user.send(user_params.keys.first)
      }
    else
      error_message = current_user.errors.full_messages.to_sentence

      render json: {
               success: false,
               html: render_to_string(
                 partial: 'layouts/flash',
                 locals: { message: error_message, type: 'error' }, # Ensure correct variables
                 formats: [:html]
               )
             },
        status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :phone_number)
  end
end
