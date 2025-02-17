class AddDepartureDateTimeToTickets < ActiveRecord::Migration[7.2]
  def change
    add_column :tickets, :departure_date, :date
    add_column :tickets, :departure_time, :time
  end
end
