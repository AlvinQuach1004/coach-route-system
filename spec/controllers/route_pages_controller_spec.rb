require 'rails_helper'

RSpec.describe RoutePagesController, type: :controller do
  describe 'GET #index' do
    let!(:location1) { create(:location, name: 'Ho Chi Minh') }
    let!(:location2) { create(:location, name: 'Ha Noi') }
    let!(:route) { create(:route, start_location: location1, end_location: location2) }
    let!(:coach) { create(:coach) }
    let!(:schedule) { create(:schedule, route: route, coach: coach) }
    let!(:stop1) { create(:stop, route: route, location: location1, is_pickup: true) }
    let!(:stop2) { create(:stop, route: route, location: location2, is_dropoff: true) }

    context 'with HTML format' do
      before { get :index }

      it 'assigns @booking as a new Booking' do
        expect(assigns(:booking)).to be_a_new(Booking)
      end

      it 'assigns @schedules' do
        expect(assigns(:schedules)).to include(schedule)
      end

      it 'assigns @schedules_without_routes' do
        expect(assigns(:schedules_without_routes)).to include(schedule)
      end

      it 'assigns @stops_with_location' do
        stops = assigns(:stops_with_location)
        expect(stops).to be_present
        expect(stops.first).to include(
          id: stop1.id,
          route: route.id,
          address: stop1.address,
          latitude: stop1.latitude_address,
          longitude: stop1.longitude_address,
          province: location1.name,
          pickup: true,
          dropoff: false
        )
      end

      it 'assigns @keywords' do
        expect(assigns(:keywords)).to be_present
      end

      it 'renders index template' do
        expect(response).to render_template(:index)
      end
    end

    context 'with Turbo Stream format' do
      before do
        get :index, format: :turbo_stream
      end

      it 'returns successful response' do
        expect(response).to be_successful
      end

      it 'renders turbo stream template' do
        expect(response.media_type).to eq Mime[:turbo_stream]
      end
    end

    context 'with search parameters' do
      context 'when searching by departure and destination' do
        before do
          get :index,
            params: {
              departure: location1.name,
              destination: location2.name
            }
        end

        it 'assigns @departure_search' do
          expect(assigns(:departure_search)).to eq(location1)
        end

        it 'assigns @destination_search' do
          expect(assigns(:destination_search)).to eq(location2)
        end
      end

      context 'with case-insensitive location search' do
        before do
          get :index,
            params: {
              departure: location1.name.downcase,
              destination: location2.name.upcase
            }
        end

        it 'finds locations regardless of case' do
          expect(assigns(:departure_search)).to eq(location1)
          expect(assigns(:destination_search)).to eq(location2)
        end
      end
    end

    context 'with pagination' do
      before do
        create_list(:schedule, 10, route: route, coach: coach)
        get :index
      end

      it 'paginates the results' do
        expect(assigns(:pagy)).to be_present
        expect(assigns(:schedules).size).to be <= Pagy::DEFAULT[:limit]
      end
    end
  end
end
