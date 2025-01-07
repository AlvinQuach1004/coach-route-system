class AddPriceToSchedule < ActiveRecord::Migration[7.2]
  def change
    add_column :schedules, :price, :decimal
  end
end
