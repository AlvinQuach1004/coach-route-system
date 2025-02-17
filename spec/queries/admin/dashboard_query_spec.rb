require 'rails_helper'

RSpec.describe Admin::DashboardQuery, type: :query do
  let(:scope) { Booking.all }
  let(:params) { {} }
  let(:query) { described_class.new(scope: scope, params: params) }

  describe '#call' do
    it 'returns expected data structure' do
      result = query.call
      expect(result).to include(:revenue_data, :bookings_by_route, :coach_status_amount, :recent_bookings, :daily_stats)
    end
  end

  describe 'private methods' do
    before do
      create_list(:booking, 3, created_at: 10.days.ago, payment_status: Booking::PaymentStatus::COMPLETED)
      create_list(:ticket, 5)
      create(:coach, status: Coach::Status::AVAILABLE)
    end

    it 'generates revenue data' do
      expect(query.send(:generate_revenue_data)).to be_a(Hash)
    end

    it 'generates bookings by route' do
      expect(query.send(:generate_bookings_by_route)).to be_an(ActiveRecord::Relation)
    end

    it 'generates coach status amount' do
      expect(query.send(:generate_coach_status_amount)).to be_a(Hash)
    end

    it 'generates recent bookings' do
      expect(query.send(:generate_recent_bookings)).to be_an(ActiveRecord::Relation)
    end

    it 'generates daily stats' do
      expect(query.send(:generate_daily_stats)).to be_a(Hash)
    end
  end
end
