class CreateTickets < ActiveRecord::Migration[7.2]
  def change
    create_table :tickets, id: :uuid do |t|
      t.references :booking, null: false, foreign_key: true, type: :uuid
      t.references :schedule, null: false, foreign_key: true, type: :uuid
      t.decimal :price
      t.string :seat_number
      t.string :status

      t.timestamps
    end
  end
end
