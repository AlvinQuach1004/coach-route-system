require 'rails_helper'

RSpec.describe Admin::ScheduleQuery, type: :query do
  let!(:route) { create(:route, start_location: create(:location, name: 'Hanoi'), end_location: create(:location, name: 'Saigon')) }
  let!(:coach) { create(:coach, license_plate: 'A-12') }
  let!(:schedule1) { create(:schedule, route: route, coach: coach, departure_time: Time.zone.parse('14:30')) }
  let!(:schedule2) { create(:schedule, route: route, coach: coach, departure_date: '02/03/2025', departure_time: Time.zone.parse('08:00'), price: 700_000) }
  let!(:schedule3) { create(:schedule, route: route, coach: coach, departure_date: '02/03/2025', departure_time: Time.zone.parse('18:00'), price: 600_000) }

  let(:scope) { Schedule.all }

  describe '#call' do
    context 'when no filters are applied' do
      it 'returns all schedules' do
        result = described_class.new(scope: scope, params: {}).call
        expect(result[:total]).to eq(3)
        expect(result[:schedules]).to match_array([schedule1, schedule2, schedule3])
      end
    end

    context 'when filtering by route' do
      it 'returns schedules matching the route' do
        result = described_class.new(scope: scope, params: { route_id: route.id }).call
        expect(result[:schedules]).to match_array([schedule1, schedule2, schedule3])
      end
    end

    context 'when filtering by coach' do
      it 'returns schedules matching the coach' do
        result = described_class.new(scope: scope, params: { coach_id: coach.id }).call
        expect(result[:schedules]).to match_array([schedule1, schedule2, schedule3])
      end
    end

    context 'when filtering by date' do
      it 'returns schedules on the specified date' do
        result = described_class.new(scope: scope, params: { start_date: '02/03/2025' }).call
        expect(result[:schedules]).to match_array([schedule2, schedule3])
      end
    end

    context 'when filtering by time' do
      it 'returns schedules matching the departure time' do
        result = described_class.new(scope: scope, params: { departure_time: '14:30' }).call
        expect(result[:schedules]).to contain_exactly(schedule1)
      end
    end

    context 'when filtering by price range' do
      it 'returns schedules within the given price range' do
        result = described_class.new(scope: scope, params: { min_price: 600_000, max_price: 700_000 }).call
        expect(result[:schedules]).to match_array([schedule2, schedule3])
      end
    end

    context 'when searching by location name' do
      it 'returns schedules with matching start or end location' do
        result = described_class.new(scope: scope, params: { search: 'Hanoi' }).call
        expect(result[:schedules]).to match_array([schedule1, schedule2, schedule3])
      end
    end

    context 'when searching by coach license plate' do
      it 'returns schedules with matching license plate' do
        result = described_class.new(scope: scope, params: { search: 'A-12' }).call
        expect(result[:schedules]).to match_array([schedule1, schedule2, schedule3])
      end
    end
  end
end
