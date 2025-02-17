require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET #show' do
    it 'renders the show template' do
      get :show
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:show)
    end
  end

  describe 'PATCH #update_field' do
    context 'with valid params' do
      it 'updates email successfully' do
        patch :update_field, params: { user: { email: 'newemail@example.com' } }, format: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['success']).to be_truthy
        expect(user.reload.email).to eq('newemail@example.com')
      end

      it 'updates phone_number successfully' do
        patch :update_field, params: { user: { phone_number: '0934567890' } }, format: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['success']).to be_truthy
        expect(user.reload.phone_number).to eq('0934567890')
      end
    end

    context 'with invalid params' do
      it 'returns an error when updating with an invalid email' do
        patch :update_field, params: { user: { email: 'invalid_email' } }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['success']).to be_falsey
        expect(user.reload.email).not_to eq('invalid_email')
      end

      it 'returns an error when updating with an empty phone number' do
        patch :update_field, params: { user: { phone_number: '' } }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['success']).to be_falsey
        expect(user.reload.phone_number).not_to eq('')
      end
    end
  end
end
