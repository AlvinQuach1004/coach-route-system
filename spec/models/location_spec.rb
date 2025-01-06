require 'rails_helper'

RSpec.describe Location, type: :model do
  it 'creates a valid location' do
    location = create(:location)
    expect(location).to be_valid
    expect(location.location_name).to eq('Default Name')
    expect(location.latitude).to eq(10.82302)
    expect(location.longitude).to eq(106.62965)
  end
end
