require 'rails_helper'

RSpec.describe BookingPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:booking) { create(:booking, user: user) }
  let(:other_user) { create(:user) }

  subject { described_class }

  describe 'permissions for #create?' do
    context 'when user is signed in' do
      it 'grants access to create booking' do
        expect(subject.new(user, booking).create?).to be(true)
      end
    end

    context 'when user is not signed in' do
      it 'denies access to create booking' do
        expect(subject.new(other_user, booking).create?).to be(false)
      end
    end
  end
end
