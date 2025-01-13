class AddPickupDropoffToStop < ActiveRecord::Migration[7.2]
  def change
    add_column :stops, :is_pickup, :boolean, default: false
    add_column :stops, :is_dropoff, :boolean, default: false
    add_column :stops, :address, :string
    add_column :stops, :latitude_address, :decimal, precision: 9, scale: 6
    add_column :stops, :longitude_address, :decimal, precision: 9, scale: 6

  end
end
