class AddStopToLocation < ActiveRecord::Migration[7.2]
  def change
    add_reference :stops, :location, null: false, foreign_key: true, type: :uuid
  end
end
