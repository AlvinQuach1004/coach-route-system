require 'rails_helper'

RSpec.describe Coach, type: :model do
  it 'creates a valid coach' do
    coach = create(:coach)
    expect(coach).to be_valid
    expect(coach.license_plate).to be_a(String)
    expect(['sleeper', 'room', 'limousine']).to include(coach.type)
    expect(coach.capacity).to be_between(30, 50)
  end
end
