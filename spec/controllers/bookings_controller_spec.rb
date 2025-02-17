# spec/controllers/bookings_controller_spec.rb
require 'rails_helper'

RSpec.describe BookingsController, type: :controller do
  let(:user) { create(:user) }
  let(:schedule) { create(:schedule) }
  let(:route) { create(:route) }
  let(:start_stop) { create(:stop, route: route, is_pickup: true) }
  let(:end_stop) { create(:stop, route: route, is_dropoff: true) }
  let(:valid_seats) { ['A1', 'A2'].to_json }
  let(:ticket_price) { 100000 }

  before do
    sign_in user
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        schedule_id: schedule.id,
        booking: {
          start_stop_id: start_stop.id,
          end_stop_id: end_stop.id,
          selected_seats: valid_seats,
          ticket_price: ticket_price,
          pickup_address: 'Pickup Location',
          dropoff_address: 'Dropoff Location'
        },
        departure_search: start_stop.location_id,
        destination_search: end_stop.location_id
      }
    end

    context 'with valid parameters' do
      before do
        allow(Stripe::Checkout::Session).to receive(:create).and_return(
          double(id: 'test_session_123')
        )
      end

      it 'creates a new booking' do
        expect do
          post :create, params: valid_params, format: :json
        end.to change(Booking, :count).by(1)
      end

      it 'creates tickets for selected seats' do
        expect do
          post :create, params: valid_params, format: :json
        end.to change(Ticket, :count).by(2)
      end

      it 'returns stripe session id' do
        post :create, params: valid_params, format: :json
        expect(response.parsed_body['session_id']).to eq('test_session_123')
      end

      it 'sets the booking status to pending' do
        post :create, params: valid_params, format: :json
        expect(Booking.last.payment_status).to eq('pending')
      end
    end

    context 'when user is not signed in' do
      before { sign_out user }

      it 'returns unauthorized error' do
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['error']).to eq(I18n.t('route_pages.bookings.errors.not_logged_in'))
      end
    end

    context 'when booking limit is reached' do
      before do
        create_list(:booking, 3, user: user, created_at: Time.zone.now)
      end

      it 'returns error message' do
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['error']).to eq(I18n.t('route_pages.bookings.errors.limit_reached'))
      end
    end
  end

  describe 'GET #invoice' do
    let(:booking) { create(:booking, user: user, stripe_session_id: 'test_session_123') }

    context 'with invalid booking' do
      it 'redirects to root path' do
        get :invoice, params: { id: 'invalid' }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Invalid booking or payment session.')
      end
    end
  end

  describe 'DELETE #cancel' do
    context 'with pending booking' do
      let!(:booking) { create(:booking, user: user, payment_status: 'pending') }

      it 'destroys the booking' do
        expect do
          delete :cancel, params: { id: booking.id }
        end.to change(Booking, :count).by(0)
      end

      it 'redirects to root path' do
        delete :cancel, params: { id: booking.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Payment was cancelled.')
      end
    end

    context 'with non-pending booking' do
      let!(:booking) { create(:booking, user: user, payment_status: 'completed') }

      it 'does not destroy the booking' do
        expect do
          delete :cancel, params: { id: booking.id }
        end.not_to change(Booking, :count)
      end
    end
  end
end
