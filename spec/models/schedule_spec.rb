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
      expect(
        [
          Schedule::Status::SCHEDULED,
          Schedule::Status::ONGOING,
          Schedule::Status::COMPLETED,
          Schedule::Status::CANCELLED,
          Schedule::Status::DELAYED
        ]
      ).to include(schedule.status)

      expect(schedule.formatted_departure_date).to eq(schedule.departure_date.strftime('%d/%m/%Y'))
      expect(schedule.formatted_departure_time).to eq(schedule.departure_time.strftime('%H:%M'))
    end
  end

  describe 'Associations' do
    it { should belong_to(:route).inverse_of(:schedules) }
    it { should belong_to(:coach).inverse_of(:schedules) }
    it { should have_many(:tickets).dependent(:destroy) }
    it { should accept_nested_attributes_for(:tickets).allow_destroy(true) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:departure_date) }
    it { should validate_presence_of(:departure_time) }

    it 'is invalid if departure_date is in the past' do
      schedule = build(:schedule, departure_date: Date.yesterday)
      expect(schedule).not_to be_valid
      expect(schedule.errors[:departure_date]).to include('cannot be in the past')
    end
  end

  describe 'Enums' do
    it 'defines the correct status values' do
      expect(described_class.statuses).to eq(
        {
          'scheduled' => 'scheduled',
          'ongoing' => 'ongoing',
          'completed' => 'completed',
          'cancelled' => 'cancelled',
          'delayed' => 'delayed'
        }
      )
    end
  end

  describe 'Callbacks' do
    let(:coach) { create(:coach, status: 'available') }
    let(:route) { create(:route) }

    context 'after_create :update_coach_status' do
      it 'updates coach status to inuse when schedule is created' do
        schedule = create(:schedule, route: route, coach: coach)
        expect(schedule.coach.status).to eq('inuse')
      end
    end

    context 'after_destroy :reset_coach_status' do
      it 'resets coach status to available when no upcoming schedules remain' do
        schedule = create(:schedule, route: route, coach: coach)
        schedule.destroy
        expect(coach.reload.status).to eq('available')
      end
    end
  end

  describe 'Public Methods' do
    let(:schedule) { build(:schedule, departure_date: Time.zone.today, departure_time: Time.zone.now) }

    it 'formats departure date correctly' do
      expect(schedule.formatted_departure_date).to eq(Time.zone.today.strftime('%d/%m/%Y'))
    end

    it 'formats departure time correctly' do
      expect(schedule.formatted_departure_time).to eq(schedule.departure_time.strftime('%H:%M'))
    end
  end

  describe '#seat_available?' do
    let(:coach) { create(:coach) }
    let(:schedule) { create(:schedule, coach: coach) }
    let!(:booked_ticket) { create(:ticket, schedule: schedule, seat_number: 5, status: 'booked') }

    it 'returns false if the seat is booked' do
      expect(schedule.seat_available?(5)).to be_falsey
    end

    it 'returns true if the seat is available' do
      expect(schedule.seat_available?(10)).to be_truthy
    end
  end

  describe '#seat_rows_by_type' do
    let(:coach_sleeper) { create(:coach, coach_type: 'sleeper') }
    let(:coach_room) { create(:coach, coach_type: 'room') }
    let(:coach_limo) { create(:coach, coach_type: 'limousine') }

    it 'returns correct seat rows for sleeper' do
      schedule = build(:schedule, coach: coach_sleeper)
      expect(schedule.seat_rows_by_type).to eq({ upper: (1..18), lower: (1..18) })
    end

    it 'returns correct seat rows for room' do
      schedule = build(:schedule, coach: coach_room)
      expect(schedule.seat_rows_by_type).to eq({ upper: (1..16), lower: (1..16) })
    end

    it 'returns correct seat rows for limousine' do
      schedule = build(:schedule, coach: coach_limo)
      expect(schedule.seat_rows_by_type).to eq({ upper: (1..14), lower: (1..14) })
    end
  end
end
