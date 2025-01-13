class AddPickupAndDropToTicket < ActiveRecord::Migration[7.2]
  def change
    add_column :tickets, :pick_up, :string
    add_column :tickets, :drop_off, :string
  end
end
