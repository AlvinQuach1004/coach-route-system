require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_one_attached(:avatar) }
  end

  describe 'validations' do
    let(:user) { build(:user) }

    context 'with valid avatar' do
      it 'is valid when the content type is correct' do
        user.avatar.attach(
          io: Rails.root.join('spec/fixtures/files/image.png').open,
          filename: 'avatar.png',
          content_type: 'image/png'
        )
        expect(user).to be_valid
      end
    end

    context 'with invalid content type' do
      it 'is invalid when the content type is incorrect' do
        user.avatar.attach(
          io: Rails.root.join('spec/fixtures/files/text.txt').open,
          filename: 'avatar.txt',
          content_type: 'text/plain'
        )
        expect(user).not_to be_valid
        expect(user.errors[:avatar]).to include('has an invalid content type')
      end
    end

    context 'with large avatar' do
      it 'is invalid when the size exceeds the limit' do
        user.avatar.attach(
          io: Rails.root.join('spec/fixtures/files/image.png').open,
          filename: 'large_image.jpg',
          content_type: 'image/jpeg'
        )
        allow(user.avatar.blob).to receive(:byte_size).and_return(11.megabytes)
        expect(user).not_to be_valid
        expect(user.errors[:avatar]).to include(I18n.t('activerecord.errors.models.user.attributes.avatar.size', size: 10))
      end
    end
  end

  describe 'Devise modules' do
    it 'includes database_authenticatable module' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable module' do
      expect(User.devise_modules).to include(:registerable)
    end

    it 'includes recoverable module' do
      expect(User.devise_modules).to include(:recoverable)
    end

    it 'includes rememberable module' do
      expect(User.devise_modules).to include(:rememberable)
    end

    it 'includes validatable module' do
      expect(User.devise_modules).to include(:validatable)
    end

    it 'includes omniauthable module' do
      expect(User.devise_modules).to include(:omniauthable)
    end
  end

  describe 'instance methods' do
    let!(:user) { create(:user) }

    describe '#admin?' do
      it 'returns true if the user has an admin role' do
        user.add_role(:admin)
        expect(user.admin?).to be true
      end

      it 'returns false if the user does not have an admin role' do
        expect(user.admin?).to be false
      end
    end

    describe '#customer?' do
      it 'returns true if the user has an customer role and is not an admin' do
        user.add_role(:customer)
        expect(user.customer?).to be true
      end

      it 'returns false if the user is an admin' do
        user.add_role(:admin)
        expect(user.customer?).to be false
      end
    end
  end
end
