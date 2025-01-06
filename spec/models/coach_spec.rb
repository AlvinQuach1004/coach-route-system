require 'rails_helper'

RSpec.describe Coach, type: :model do
  it 'creates a valid coach' do
    coach = create(:coach)
    expect(coach).to be_valid
    expect(coach.license_plate).to eq('MyString')
    expect(coach.type).to eq('available')
    expect(coach.capacity).to eq(41)
  end
end
