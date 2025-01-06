require 'rails_helper'

RSpec.describe Booking, type: :model do
  it 'creates a valid booking' do
    booking = create(:booking)
    expect(booking).to be_valid
    expect(booking.user).to be_present
    expect(booking.payment_method).to eq('online')
    expect(booking.payment_status).to eq('pending')
    expect(booking.start_stop).to be_present
    expect(booking.end_stop).to be_present
  end
end
