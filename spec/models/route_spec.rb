require 'rails_helper'

RSpec.describe Route, type: :model do
  it 'creates a route with different locations' do
    route = create(:route, same_location: false)
    expect(route.start_location).not_to eq(route.end_location)
  end
end
