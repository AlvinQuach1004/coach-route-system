require 'rails_helper'

RSpec.describe Stop, type: :model do
  describe 'associations' do
    it { should belong_to(:route).inverse_of(:stops) }
    it { should belong_to(:location).inverse_of(:stops) }
    it { should have_many(:start_stops).class_name('Booking').with_foreign_key(:start_stop_id).dependent(:destroy).inverse_of(:start_stop) }
    it { should have_many(:end_stops).class_name('Booking').with_foreign_key(:end_stop_id).dependent(:destroy).inverse_of(:end_stop) }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      stop = build(:stop)
      expect(stop).to be_valid
    end

    it { should validate_presence_of(:stop_order) }
    it { should validate_numericality_of(:stop_order).is_greater_than_or_equal_to(1).is_less_than_or_equal_to(10) }

    it { should validate_numericality_of(:time_range).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(360) }

    it { should validate_length_of(:address).is_at_most(255) }

    it { should validate_inclusion_of(:is_pickup).in_array([true, false]) }
    it { should validate_inclusion_of(:is_dropoff).in_array([true, false]) }
  end
end
