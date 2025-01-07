require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe 'validations and associations' do
    it 'creates a valid ticket' do
      ticket = create(:ticket)
      expect(ticket).to be_valid
      expect(ticket.booking).to be_present
      expect(ticket.schedule).to be_present
      expect(ticket.paid_amount.to_f).to be_a(Float)
      expect(ticket.seat_number).to be_a(String)
      expect(['booked', 'paid', 'cancelled']).to include(ticket.status)
    end
  end
end
