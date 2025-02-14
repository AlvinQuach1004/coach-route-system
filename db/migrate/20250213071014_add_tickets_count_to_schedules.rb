class AddTicketsCountToSchedules < ActiveRecord::Migration[7.2]
  def change
    add_column :schedules, :tickets_count, :integer, default: 0
  end
end
