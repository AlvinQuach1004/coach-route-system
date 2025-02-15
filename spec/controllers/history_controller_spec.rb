require 'rails_helper'

RSpec.describe HistoryController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:bookings) { create_list(:booking, 5, user: user) }
  let!(:other_bookings) { create_list(:booking, 3, user: other_user) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    context 'when user is signed in' do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "assigns only the current user's bookings" do
        get :index
        expect(assigns(:bookings)).to match_array(user.bookings)
        expect(assigns(:bookings)).not_to include(*other_user.bookings)
      end

      it 'assigns the correct total_bookings count' do
        get :index
        expect(assigns(:total_bookings)).to eq(user.bookings.count)
      end
    end

    context 'when user is not signed in' do
      before do
        sign_out user
      end

      it 'redirects to sign-in page' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
