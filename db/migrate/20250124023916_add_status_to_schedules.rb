class AddStatusToSchedules < ActiveRecord::Migration[7.2]
  def change
    add_column :schedules, :status, :string, default: 'scheduled'
  end
end
