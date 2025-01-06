class ChangeLocationNameInLocation < ActiveRecord::Migration[7.2]
  def change
    rename_column(:locations, :location_name, :name)
  end
end
