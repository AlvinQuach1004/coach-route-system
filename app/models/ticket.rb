# == Schema Information
#
# Table name: tickets
#
#  id             :uuid             not null, primary key
#  departure_date :date
#  departure_time :time
#  drop_off       :string
#  paid_amount    :decimal(, )
#  pick_up        :string
#  seat_number    :string
#  status         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  booking_id     :uuid             not null
#  schedule_id    :uuid             not null
#
# Indexes
#
#  index_tickets_on_booking_id                   (booking_id)
#  index_tickets_on_schedule_id                  (schedule_id)
#  index_tickets_on_schedule_id_and_seat_number  (schedule_id,seat_number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (schedule_id => schedules.id)
#
class Ticket < ApplicationRecord
  # Associations
  belongs_to :booking, inverse_of: :tickets
  belongs_to :schedule, counter_cache: true, inverse_of: :tickets

  # Constants
  module Status
    BOOKED = 'booked'.freeze
    PAID = 'paid'.freeze
    CANCELLED = 'cancelled'.freeze

    ALL = [BOOKED, PAID, CANCELLED].freeze
  end

  # Enumerize
  enum :status,
    {
      booked: Status::BOOKED,
      paid: Status::PAID,
      cancelled: Status::CANCELLED
    },
    default: Status::PAID

  # Validations
  validates :paid_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :seat_number, presence: true, uniqueness: { scope: :schedule_id, message: 'is already booked for this schedule' }

  def formatted_departure_date
    departure_date.strftime('%d/%m/%Y') if departure_date.present?
  end

  def formatted_departure_time
    departure_time.strftime('%H:%M') if departure_time.present?
  end
end
