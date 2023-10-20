class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :partner, null: false, foreign_key: true
      t.string :title
      t.string :description
      t.integer :notification_type
      t.boolean :readed, default: false

      t.timestamps
    end
  end
end
