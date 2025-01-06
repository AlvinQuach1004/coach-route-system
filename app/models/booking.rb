# == Schema Information
#
# Table name: bookings
#
#  id             :uuid             not null, primary key
#  payment_method :string           not null
#  payment_status :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  end_stop_id    :uuid             not null
#  start_stop_id  :uuid             not null
#  user_id        :uuid             not null
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
  belongs_to :user, inverse_of: :bookings
  has_many :tickets, dependent: :destroy, inverse_of: :booking
  belongs_to :start_stop, class_name: 'Stop', inverse_of: :start_stops
  belongs_to :end_stop, class_name: 'Stop', inverse_of: :end_stops
  validate :start_and_stop_cannot_be_the_same

  enum :payment_method, { online: 'online', cash: 'cash' }, default: :cash
  enum :payment_status, { pending: 'pending', completed: 'completed', failed: 'failed' }, default: :pending

  private

  def start_and_stop_cannot_be_the_same
    if start_stop == end_stop
      errors.add(:end_stop, 'must be different from start_stop')
    end
  end
end
