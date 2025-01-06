class AddUniqueIndexToTickets < ActiveRecord::Migration[7.2]
  def change
    add_index :tickets, [:schedule_id, :seat_number], unique: true
  end
end
