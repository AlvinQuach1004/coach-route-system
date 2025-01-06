# == Schema Information
#
# Table name: coaches
#
#  id            :uuid             not null, primary key
#  capacity      :integer
#  license_plate :string
#  type          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Coach < ApplicationRecord
  # Associations
  has_many :schedules, dependent: :destroy, inverse_of: :coach

  # Validations
  validates :license_plate, presence: true
  validates :type, presence: true, inclusion: { in: %w[limousine sleeper room] }
  validates :capacity, presence: true, numericality: { greater_than_or_equal_to: 30, less_than_or_equal_to: 50 }
end
