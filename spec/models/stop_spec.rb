require 'rails_helper'

RSpec.describe Stop, type: :model do
  describe 'Validations' do
    it 'is valid with valid attributes' do
      stop = build(:stop)
      expect(stop).to be_valid
    end
  end
end
