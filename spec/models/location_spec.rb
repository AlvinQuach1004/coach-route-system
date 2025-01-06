require 'rails_helper'

RSpec.describe Location, type: :model do
  it 'creates a valid location' do
    location = create(:location)
    expect(location).to be_valid
    expect(location.name).to be_present
    expect(location.latitude.to_f).to be_a(Float)
    expect(location.longitude.to_f).to be_a(Float)
  end
end
