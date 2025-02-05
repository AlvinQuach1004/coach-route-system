# == Schema Information
#
# Table name: coaches
#
#  id            :uuid             not null, primary key
#  capacity      :integer
#  coach_type    :string
#  license_plate :string
#  status        :string           default("available")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Coach < ApplicationRecord
  # Associations
  has_many :schedules, dependent: :destroy, inverse_of: :coach

  # Callbacks
  before_validation :set_default_capacity, on: :create

  # Constants
  module Capacity
    LIMOUSINE = 28
    ROOM = 32
    SLEEPER = 36

    ALL = [LIMOUSINE, ROOM, SLEEPER].freeze
  end

  module Status
    AVAILABLE = 'available'.freeze
    INUSE = 'in use'.freeze
    MAINTAINANCE = 'maintainance'.freeze

    ALL = [AVAILABLE, INUSE, MAINTAINANCE].freeze
  end

  # Enumerize
  enum :status,
    {
      available: Status::AVAILABLE,
      inuse: Status::INUSE,
      maintainance: Status::MAINTAINANCE
    },
    default: Status::AVAILABLE

  # Validations
  validates :license_plate, presence: true
  validates :coach_type, presence: true, inclusion: { in: %w[limousine sleeper room] }
  validates :capacity, presence: true, numericality: { greater_than_or_equal_to: Coach::Capacity::LIMOUSINE, less_than_or_equal_to: Coach::Capacity::SLEEPER }

  private

  def set_default_capacity
    self.capacity = case coach_type
                    when 'limousine' then Capacity::LIMOUSINE
                    when 'room' then Capacity::ROOM
                    when 'sleeper' then Capacity::SLEEPER
                    end
  end
end
