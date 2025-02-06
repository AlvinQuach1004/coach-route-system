class AddBookingIdToNotifications < ActiveRecord::Migration[7.2]
  def change
    add_reference :notifications, :booking, foreign_key: true, type: :uuid
    add_index :notifications, [:user_id, :booking_id]
  end
end
