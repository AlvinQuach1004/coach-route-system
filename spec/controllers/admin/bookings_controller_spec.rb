require 'rails_helper'

RSpec.describe Admin::BookingsController, type: :controller do
  let!(:admin) { create(:user, :admin) }
  let!(:user) { create(:user) }
  let!(:booking) { create(:booking, user: user) }

  before do
    sign_in admin
  end

  describe 'GET #index' do
    it 'renders the index template and assigns @bookings' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(assigns(:bookings)).to include(booking)
    end
  end

  describe 'GET #show' do
    it 'renders the show template' do
      get :show, params: { id: booking.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH #update' do
    context 'when update is successful' do
      it 'updates the payment_status and redirects' do
        patch :update, params: { id: booking.id }
        booking.reload
        expect(booking.payment_status).to eq('completed')
        expect(response).to redirect_to(admin_booking_path(booking))
      end
    end

    context 'when update fails' do
      before do
        allow_any_instance_of(Booking).to receive(:update).and_return(false)
      end

      it 'sets flash error and redirects to booking page' do
        patch :update, params: { id: booking.id }
        expect(flash[:error]).to eq('Failed to update payment status.')
        expect(response).to redirect_to(admin_booking_path(booking))
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the booking and redirects' do
      expect do
        delete :destroy, params: { id: booking.id }
      end.to change(Booking, :count).by(-1)
      expect(response).to redirect_to(admin_bookings_path)
    end
  end
end
