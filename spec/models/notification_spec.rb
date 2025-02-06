require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:notification) { build(:notification) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(notification).to be_valid
    end

    it 'is not valid without a user' do
      notification.user = nil
      expect(notification).to_not be_valid
    end

    it 'is not valid without booking' do
      notification.booking = nil
      expect(notification).to_not be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:booking) }
  end
end
