class CreateNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :notifications, id: :uuid do |t|
      t.string :title
      t.text :body
      t.boolean :is_read
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
