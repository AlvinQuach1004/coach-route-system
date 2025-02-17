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

  describe 'associations' do
    it { should belong_to(:booking).inverse_of(:tickets) }
    it { should belong_to(:schedule).counter_cache(true).inverse_of(:tickets) }
  end

  describe 'validations' do
    it { should validate_presence_of(:paid_amount) }
    it { should validate_numericality_of(:paid_amount).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:seat_number) }

    it 'validates uniqueness of seat_number scoped to schedule_id' do
      schedule = create(:schedule)
      create(:ticket, schedule: schedule, seat_number: 'A1')
      should validate_uniqueness_of(:seat_number).scoped_to(:schedule_id).with_message('is already booked for this schedule')
    end
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(booked: 'booked', paid: 'paid', cancelled: 'cancelled').backed_by_column_of_type(:string) }

    it 'allows valid status values' do
      expect { build(:ticket, status: 'booked') }.not_to raise_error
      expect { build(:ticket, status: 'paid') }.not_to raise_error
      expect { build(:ticket, status: 'cancelled') }.not_to raise_error
    end

    it 'raises error for invalid status value' do
      expect { build(:ticket, status: 'invalid_status') }.to raise_error(ArgumentError)
    end
  end
end
