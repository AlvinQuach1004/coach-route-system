require 'rails_helper'

RSpec.describe Booking, type: :model do
  it 'creates a valid booking' do
    booking = create(:booking)

    expect(booking).to be_valid
    expect(['online']).to include(booking.payment_method)
    expect(['pending', 'completed', 'failed']).to include(booking.payment_status)
    expect(booking.start_stop).to be_present
    expect(booking.end_stop).to be_present
  end
end
