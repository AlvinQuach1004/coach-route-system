class CreateSchedules < ActiveRecord::Migration[7.2]
  def change
    create_table :schedules, id: :uuid do |t|
      t.references :route, null: false, foreign_key: true, type: :uuid
      t.date :departure_date
      t.time :departure_time
      t.references :coach, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
