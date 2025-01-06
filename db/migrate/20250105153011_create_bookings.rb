class CreateBookings < ActiveRecord::Migration[7.2]
  def change
    create_table :bookings, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :payment_method, null: false
      t.string :payment_status, null: false
      t.references :start_stop, null: false, foreign_key: { to_table: :stops }, type: :uuid
      t.references :end_stop, null: false, foreign_key: { to_table: :stops }, type: :uuid
      t.timestamps
    end
  end
end
