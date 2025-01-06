class CreateLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :locations, id: :uuid do |t|
      t.string :location_name
      t.decimal :longitude
      t.decimal :latitude

      t.timestamps
    end
  end
end
