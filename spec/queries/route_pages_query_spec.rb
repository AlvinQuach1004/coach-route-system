require 'rails_helper'

RSpec.describe RoutePagesQuery, type: :query do
  let!(:location1) { create(:location, name: 'Hanoi') }
  let!(:location2) { create(:location, name: 'Saigon') }
  let!(:route) { create(:route, start_location: location1, end_location: location2) }
  let!(:coach) { create(:coach, coach_type: 'sleeper', capacity: 40) }
  let!(:schedule) { create(:schedule, route: route, coach: coach, departure_date: Time.zone.today, price: 100) }
  let!(:another_schedule) { create(:schedule, route: route, coach: coach, departure_date: Date.tomorrow, price: 150) }
  let(:scope) { Schedule.all }

  describe '#call' do
    context 'when no filters are applied' do
      it 'returns all schedules' do
        result = RoutePagesQuery.new(scope: scope, params: {}).call
        expect(result[:total]).to eq(2)
        expect(result[:schedules]).to match_array([schedule, another_schedule])
      end
    end

    context 'when filtering by category' do
      it 'returns schedules matching the category' do
        result = RoutePagesQuery.new(scope: scope, params: { category: 'Giường nằm' }).call
        expect(result[:schedules]).to include(schedule, another_schedule)
      end
    end

    context 'when filtering by departure location' do
      it 'returns schedules departing from specified location' do
        result = RoutePagesQuery.new(scope: scope, params: { departure: 'Hà Nội' }).call
        expect(result[:schedules]).to include(schedule, another_schedule)
      end
    end

    context 'when filtering by destination' do
      it 'returns schedules arriving at specified destination' do
        result = RoutePagesQuery.new(scope: scope, params: { destination: 'TP. Hồ Chí Minh' }).call
        expect(result[:schedules]).to include(schedule, another_schedule)
      end
    end

    context 'when filtering by date' do
      it 'returns schedules for the given date' do
        result = RoutePagesQuery.new(scope: scope, params: { date: Time.zone.today.to_s }).call
        expect(result[:schedules]).to eq([schedule])
      end
    end

    context 'when filtering by price' do
      it 'returns schedules within the specified price range' do
        result = RoutePagesQuery.new(scope: scope, params: { price: 120 }).call
        expect(result[:schedules]).to eq([schedule])
      end
    end

    context 'when sorting by price' do
      it 'returns schedules sorted by price descending' do
        result = RoutePagesQuery.new(scope: scope, params: { sort_by: 'price_high_to_low' }).call
        expect(result[:schedules].first).to eq(another_schedule)
      end

      it 'returns schedules sorted by price ascending' do
        result = RoutePagesQuery.new(scope: scope, params: { sort_by: 'price_low_to_high' }).call
        expect(result[:schedules].first).to eq(schedule)
      end
    end
  end
end
