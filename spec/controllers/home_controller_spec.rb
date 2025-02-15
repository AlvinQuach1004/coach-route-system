require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  render_views

  let!(:start_location) { create(:location, name: 'Hanoi') }
  let!(:end_location) { create(:location, name: 'Saigon') }
  let!(:route1) { create(:route, start_location: start_location, end_location: end_location) }
  let!(:route2) { create(:route, start_location: start_location, end_location: create(:location, name: 'Danang')) }
  let!(:route3) { create(:route, start_location: create(:location, name: 'Hue'), end_location: end_location) }

  let!(:schedule1) { create(:schedule, route: route1, departure_date: Time.zone.today.next_week.beginning_of_week) }
  let!(:schedule2) { create(:schedule, route: route1, departure_date: Time.zone.today.next_week.beginning_of_week + 1.day) }
  let!(:schedule3) { create(:schedule, route: route2, departure_date: Time.zone.today.next_week.beginning_of_week + 2.days) }
  let!(:schedule4) { create(:schedule, route: route3, departure_date: Time.zone.today.end_of_week) }

  describe 'GET #index' do
    before { get :index }
    before do
      allow_any_instance_of(Schedule).to receive(:departure_date_cannot_be_in_the_past).and_return(true)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @top_routes_of_week' do
      expect(assigns(:top_routes_of_week)).to be_present
      expect(assigns(:top_routes_of_week).size).to be <= 3
    end

    it 'assigns @most_popular_routes' do
      expect(assigns(:most_popular_routes)).to be_present
      expect(assigns(:most_popular_routes).size).to be <= 8
    end

    it 'ensures routes are ordered correctly' do
      top_routes = assigns(:top_routes_of_week)
      expect(top_routes).to eq(top_routes.sort_by { |r| -r.route_count.to_i })
    end
  end
end
