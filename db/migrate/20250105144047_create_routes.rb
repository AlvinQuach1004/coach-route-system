class CreateRoutes < ActiveRecord::Migration[7.2]
  def change
    create_table :routes, id: :uuid do |t|
      t.references :start_location, null: false, foreign_key: { to_table: :locations }, type: :uuid
      t.references :end_location, null: false, foreign_key: { to_table: :locations }, type: :uuid
      t.timestamps
    end
  end
end
