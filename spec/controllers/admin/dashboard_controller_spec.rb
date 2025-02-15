require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :controller do
  let(:admin) { create(:user, :admin) }

  before do
    sign_in admin
    get :index
  end

  describe 'GET #index' do
    let(:bookings) { create_list(:booking, 5) }
    let(:query_instance) { instance_double(Admin::DashboardQuery) }
    let(:query_result) do
      {
        revenue_data: { total: 1000 },
        bookings_by_route: { 'Route A' => 3, 'Route B' => 2 },
        coach_status_amount: { active: 2, inactive: 1 },
        recent_bookings: bookings,
        daily_stats: { today: 10, yesterday: 8 }
      }
    end

    before do
      allow(Admin::DashboardQuery).to receive(:new).and_return(query_instance)
      allow(query_instance).to receive(:call).and_return(query_result)

      get :index
    end

    it 'returns a successful response' do
      expect(response).to have_http_status(:ok)
    end

    it 'calls DashboardQuery with correct parameters' do
      expect(Admin::DashboardQuery).to have_received(:new).with(scope: Booking.all, params: instance_of(ActionController::Parameters))
      expect(query_instance).to have_received(:call)
    end

    it 'assigns the correct instance variables' do
      expect(assigns(:revenue_data)).to eq(query_result[:revenue_data])
      expect(assigns(:bookings_by_route)).to eq(query_result[:bookings_by_route])
      expect(assigns(:coach_status_amount)).to eq(query_result[:coach_status_amount])
      expect(assigns(:recent_bookings)).to eq(query_result[:recent_bookings])
      expect(assigns(:daily_stats)).to eq(query_result[:daily_stats])
    end
  end
end
