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
      expect(schedule.price.to_f).to be_a(Float)
      expect(['scheduled', 'ongoing', 'completed', 'cancelled', 'delayed']).to include(schedule.status)

      expect(schedule.formatted_departure_date).to eq(schedule.departure_date.strftime('%d/%m/%Y'))
      expect(schedule.formatted_departure_time).to eq(schedule.departure_time.strftime('%H:%M'))
    end
  end
end
