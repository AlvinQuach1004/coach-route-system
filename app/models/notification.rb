# == Schema Information
#
# Table name: notifications
#
#  id         :uuid             not null, primary key
#  body       :text
#  is_read    :boolean
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  booking_id :uuid
#  user_id    :uuid             not null
#
# Indexes
#
#  index_notifications_on_booking_id              (booking_id)
#  index_notifications_on_user_id                 (user_id)
#  index_notifications_on_user_id_and_booking_id  (user_id,booking_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (user_id => users.id)
#
class Notification < ApplicationRecord
  belongs_to :user, inverse_of: :notifications
  belongs_to :booking, inverse_of: :notifications
  scope :unread, -> { where(is_read: false) }

  def mark_as_read
    update(is_read: true)
  end
end
