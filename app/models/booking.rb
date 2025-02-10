# == Schema Information
#
# Table name: bookings
#
#  id                       :uuid             not null, primary key
#  payment_method           :string           not null
#  payment_status           :string           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  end_stop_id              :uuid             not null
#  start_stop_id            :uuid             not null
#  stripe_payment_intent_id :string
#  stripe_session_id        :string
#  user_id                  :uuid             not null
#
# Indexes
#
#  index_bookings_on_end_stop_id    (end_stop_id)
#  index_bookings_on_start_stop_id  (start_stop_id)
#  index_bookings_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (end_stop_id => stops.id)
#  fk_rails_...  (start_stop_id => stops.id)
#  fk_rails_...  (user_id => users.id)
#
class Booking < ApplicationRecord
  # Associations
  belongs_to :user, inverse_of: :bookings
  has_many :tickets, dependent: :destroy, inverse_of: :booking
  belongs_to :start_stop, class_name: 'Stop', inverse_of: :start_stops
  belongs_to :end_stop, class_name: 'Stop', inverse_of: :end_stops
  has_many :notification_mentions, as: :record, dependent: :destroy, class_name: 'Noticed::Event'

  # Constants
  module PaymentMethod
    STRIPE = 'stripe'.freeze
    CASH = 'cash'.freeze

    ALL = [STRIPE, CASH].freeze
  end

  # Constants for payment status
  module PaymentStatus
    PENDING = 'pending'.freeze
    COMPLETED = 'completed'.freeze
    FAILED = 'failed'.freeze

    ALL = [PENDING, COMPLETED, FAILED].freeze
  end

  # Validations
  validate :start_and_stop_cannot_be_the_same

  # Scopes
  scope :search,
    ->(query) {
      return all if query.blank?

      joins(:user, start_stop: :location, end_stop: :location)
        .where('users.email ILIKE :q OR locations.name ILIKE :q', q: "%#{query}%")
    }

  scope :filter_by_status,
    ->(status) {
      return all if status.blank?

      where(payment_status: status)
    }

  scope :filter_by_date_range,
    ->(start_date, end_date) {
      return all if start_date.blank? || end_date.blank?

      joins(tickets: :schedule)
        .where(schedules: { departure_date: start_date..end_date })
    }

  # Enumerize
  enum :payment_method,
    {
      online: PaymentMethod::STRIPE,
      cash: PaymentMethod::CASH
    },
    default: PaymentMethod::CASH

  enum :payment_status,
    {
      pending: PaymentStatus::PENDING,
      completed: PaymentStatus::COMPLETED,
      failed: PaymentStatus::FAILED
    },
    default: PaymentStatus::PENDING

  private

  def start_and_stop_cannot_be_the_same
    if start_stop == end_stop
      errors.add(:end_stop, 'must be different from start_stop')
    end
  end
end
