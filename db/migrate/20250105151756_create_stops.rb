class CreateStops < ActiveRecord::Migration[7.2]
  def change
    create_table :stops, id: :uuid do |t|
      t.references :route, null: false, foreign_key: true, type: :uuid
      t.integer :stop_order
      t.integer :time_range

      t.timestamps
    end
  end
end
