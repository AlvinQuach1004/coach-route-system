class DropNotifications < ActiveRecord::Migration[7.0]
  def up
    drop_table :notifications
  end

  def down
    create_table :notifications, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string :title
      t.text :body
      t.boolean :is_read
      t.uuid :user_id, null: false
      t.uuid :booking_id
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index ["booking_id"], name: "index_notifications_on_booking_id"
      t.index ["user_id", "booking_id"], name: "index_notifications_on_user_id_and_booking_id"
      t.index ["user_id"], name: "index_notifications_on_user_id"
    end
  end
end
