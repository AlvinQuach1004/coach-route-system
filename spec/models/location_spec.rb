require 'rails_helper'

RSpec.describe Location, type: :model do
  it 'creates a valid location' do
    location = create(:location)
    expect(location).to be_valid
    expect(location.name).to be_present
    expect(location.latitude.to_f).to be_a(Float)
    expect(location.longitude.to_f).to be_a(Float)
  end

  describe 'Validations' do
    it 'is valid with valid attributes' do
      location = build(:location)
      expect(location).to be_valid
    end

    it 'is invalid without a name' do
      location = build(:location, name: nil)
      expect(location).not_to be_valid
      expect(location.errors[:name]).to include("can't be blank")
    end

    it 'is invalid without a latitude' do
      location = build(:location, latitude: nil)
      expect(location).not_to be_valid
      expect(location.errors[:latitude]).to include("can't be blank")
    end

    it 'is invalid without a longitude' do
      location = build(:location, longitude: nil)
      expect(location).not_to be_valid
      expect(location.errors[:longitude]).to include("can't be blank")
    end
  end

  describe 'Associations' do
    it { should have_many(:stops).dependent(:destroy).inverse_of(:location) }
    it { should have_many(:start_routes).class_name('Route').with_foreign_key('start_location_id').dependent(:destroy).inverse_of(:start_location) }
    it { should have_many(:end_routes).class_name('Route').with_foreign_key('end_location_id').dependent(:destroy).inverse_of(:end_location) }
  end
end
