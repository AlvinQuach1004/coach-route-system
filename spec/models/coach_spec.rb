require 'rails_helper'

RSpec.describe Coach, type: :model do
  it 'creates a valid coach' do
    coach = create(:coach)
    expect(coach).to be_valid
    expect(coach.license_plate).to be_a(String)
    expect(['sleeper', 'room', 'limousine']).to include(coach.coach_type)
    expect(coach.capacity).to be_between(28, 36)
  end

  describe 'Validations' do
    it 'is invalid without a license_plate' do
      coach = build(:coach, license_plate: nil)
      expect(coach).not_to be_valid
      expect(coach.errors[:license_plate]).to include("can't be blank")
    end

    it 'is invalid without a coach_type' do
      coach = build(:coach, coach_type: nil)
      expect(coach).not_to be_valid
      expect(coach.errors[:coach_type]).to include("can't be blank")
    end

    it 'is invalid with an invalid coach_type' do
      coach = build(:coach, coach_type: 'invalid_type')
      expect(coach).not_to be_valid
      expect(coach.errors[:coach_type]).to include('is not included in the list')
    end

    before do
      Coach.skip_callback(:validation, :before, :set_default_capacity)
    end

    after do
      Coach.set_callback(:validation, :before, :set_default_capacity)
    end

    it 'is invalid without a capacity' do
      coach = build(:coach, capacity: nil)
      expect(coach).not_to be_valid
      expect(coach.errors[:capacity]).to include("can't be blank")
    end

    it 'is invalid with a capacity less than the minimum' do
      coach = build(:coach, capacity: Coach::Capacity::LIMOUSINE - 1)
      expect(coach).not_to be_valid
      expect(coach.errors[:capacity]).to include("must be greater than or equal to #{Coach::Capacity::LIMOUSINE}")
    end

    it 'is invalid with a capacity greater than the maximum' do
      coach = build(:coach, capacity: Coach::Capacity::SLEEPER + 1)
      expect(coach).not_to be_valid
      expect(coach.errors[:capacity]).to include("must be less than or equal to #{Coach::Capacity::SLEEPER}")
    end
  end

  describe 'Callbacks' do
    it 'sets the default capacity based on coach_type before validation' do
      coach = build(:coach, capacity: nil, coach_type: 'limousine')
      coach.validate
      expect(coach.capacity).to eq(Coach::Capacity::LIMOUSINE)

      coach = build(:coach, capacity: nil, coach_type: 'room')
      coach.validate
      expect(coach.capacity).to eq(Coach::Capacity::ROOM)

      coach = build(:coach, capacity: nil, coach_type: 'sleeper')
      coach.validate
      expect(coach.capacity).to eq(Coach::Capacity::SLEEPER)
    end
  end
end
