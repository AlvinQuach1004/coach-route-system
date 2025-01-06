class ChangeLatitudeLongitudeFromLocation < ActiveRecord::Migration[7.2]
  def change
    change_column :locations, :latitude, :decimal, precision: 9, scale: 6
    change_column :locations, :longitude, :decimal, precision: 9, scale: 6
  end
end
