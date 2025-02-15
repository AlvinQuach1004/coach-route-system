require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }

  before do
    sign_in admin
  end

  describe 'GET #index' do
    it 'renders the index template' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    it 'renders the edit template' do
      get :edit, params: { id: user.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let(:new_email) { 'newemail@example.com' }
    let(:phone_number) { '0941499757' }

    it 'updates a user successfully' do
      patch :update, params: { id: user.id, user: { email: new_email, phone_number: phone_number } }
      puts response.body
      puts user.reload.errors.full_messages
      expect(user.reload.email).to eq(new_email)
      expect(response).to redirect_to(admin_users_path)
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes the user' do
      user
      expect do
        delete :destroy, params: { id: user.id }
      end.to change(User, :count).by(-1)
    end
  end
end
