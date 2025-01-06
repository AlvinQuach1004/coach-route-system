require 'rails_helper'

RSpec.describe Schedule, type: :model do
  describe 'validations and associations' do
    let(:route) { create(:route) }
    let(:coach) { create(:coach) }

    it 'creates a valid schedule' do
      schedule = create(:schedule, route: route, coach: coach)

      expect(schedule).to be_valid
      expect(schedule.route).to eq(route)
      expect(schedule.coach).to eq(coach)
      expect(schedule.formatted_departure_date).to eq('12/12/2025')
      expect(schedule.formatted_departure_time).to eq('22:28:48')
    end
  end
end
