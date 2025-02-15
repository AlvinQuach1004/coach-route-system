require 'rails_helper'

RSpec.describe Booking, type: :model do
  describe 'associations' do
    it { should belong_to(:user).inverse_of(:bookings) }
    it { should have_many(:tickets).dependent(:destroy).inverse_of(:booking) }
    it { should belong_to(:start_stop).class_name('Stop').inverse_of(:start_stops) }
    it { should belong_to(:end_stop).class_name('Stop').inverse_of(:end_stops) }
    it { should have_many(:notification_mentions).class_name('Noticed::Event').dependent(:destroy) }
  end

  describe 'validations' do
    it 'creates a valid booking' do
      booking = create(:booking)

      expect(booking).to be_valid
      expect(['online']).to include(booking.payment_method)
      expect(['pending', 'completed', 'failed']).to include(booking.payment_status)
      expect(booking.start_stop).to be_present
      expect(booking.end_stop).to be_present
    end
    context 'when start_stop and end_stop are the same' do
      let(:stop) { create(:stop) }
      let(:booking) { build(:booking, start_stop: stop, end_stop: stop) }

      it 'is not valid' do
        expect(booking).not_to be_valid
        expect(booking.errors[:end_stop]).to include('must be different from start_stop')
      end
    end
  end

  describe 'scopes' do
    let(:user1) { create(:user, email: 'test@example.com') }
    let(:user2) { create(:user, email: 'other@example.com') }
    let(:location1) { create(:location, name: 'New York') }
    let(:location2) { create(:location, name: 'Los Angeles') }
    let(:stop1) { create(:stop, location: location1) }
    let(:stop2) { create(:stop, location: location2) }
    let!(:booking1) { create(:booking, user: user1, start_stop: stop1, end_stop: stop2) }
    let!(:booking2) { create(:booking, user: user2, start_stop: stop2, end_stop: stop1) }

    describe '.search' do
      it 'finds bookings by user email' do
        expect(Booking.search('test@example.com')).to include(booking1)
        expect(Booking.search('test@example.com')).not_to include(booking2)
      end

      it 'finds bookings by location name' do
        expect(Booking.search('New York')).to include(booking1)
        expect(Booking.search('New York')).not_to include(booking2)
      end
    end

    describe '.filter_by_status' do
      let!(:pending_booking) { create(:booking, payment_status: 'pending') }
      let!(:completed_booking) { create(:booking, payment_status: 'completed') }

      it 'filters bookings by payment status' do
        expect(Booking.filter_by_status('pending')).to include(pending_booking)
        expect(Booking.filter_by_status('pending')).not_to include(completed_booking)
      end
    end

    describe '.filter_by_date_range' do
      let(:schedule1) { create(:schedule, departure_date: Time.zone.today) }
      let(:schedule2) { create(:schedule, departure_date: Time.zone.today + 7.days) }
      let!(:ticket1) { create(:ticket, schedule: schedule1, booking: booking1) }
      let!(:ticket2) { create(:ticket, schedule: schedule2, booking: booking2) }

      it 'filters bookings within a date range' do
        expect(Booking.filter_by_date_range(Time.zone.today, Time.zone.today)).to include(booking1)
        expect(Booking.filter_by_date_range(Time.zone.today, Time.zone.today)).not_to include(booking2)
      end
    end
  end

  describe 'enums' do
    it { should define_enum_for(:payment_method).with_values(online: Booking::PaymentMethod::STRIPE).backed_by_column_of_type(:string) }
    it {
      should define_enum_for(:payment_status).with_values(
        pending: Booking::PaymentStatus::PENDING,
        completed: Booking::PaymentStatus::COMPLETED,
        failed: Booking::PaymentStatus::FAILED
      ).backed_by_column_of_type(:string)
    }
  end
end
