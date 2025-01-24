class AddStatusToCoach < ActiveRecord::Migration[7.2]
  def change
    add_column :coaches, :status, :string, default: 'available'
  end
end
