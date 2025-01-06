require 'rails_helper'

RSpec.describe Ticket, type: :model do
  it 'creates a valid ticket with associated booking and schedule' do
    ticket = create(:ticket)
    expect(ticket).to be_valid
    expect(ticket.booking).to be_present
    expect(ticket.schedule).to be_present
    expect(ticket.price).to eq(9.99)
    expect(ticket.seat_number).to eq('MyString')
    expect(ticket.status).to eq('booked')
  end
end
