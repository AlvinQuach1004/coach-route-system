# == Schema Information
#
# Table name: tickets
#
#  id          :uuid             not null, primary key
#  price       :decimal(, )
#  seat_number :string
#  status      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  booking_id  :uuid             not null
#  schedule_id :uuid             not null
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
  belongs_to :schedule, inverse_of: :tickets

  # Enumerize
  enum :status, { booked: 'booked', paid: 'paid', cancelled: 'cancelled' }, default: :booked

  # Validations
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :seat_number, presence: true, uniqueness: { scope: :schedule_id, message: 'is already booked for this schedule' }
end
