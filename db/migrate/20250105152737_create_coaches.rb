class CreateCoaches < ActiveRecord::Migration[7.2]
  def change
    create_table :coaches, id: :uuid do |t|
      t.string :license_plate
      t.string :type
      t.integer :capacity

      t.timestamps
    end
  end
end
