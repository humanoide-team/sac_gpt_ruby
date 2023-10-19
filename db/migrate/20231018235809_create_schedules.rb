class CreateSchedules < ActiveRecord::Migration[6.1]
  def change
    create_table :schedules do |t|
      t.integer :schedule_type
      t.string :summary
      t.string :description
      t.datetime :date_time_start
      t.datetime :date_time_end
      t.string :event
      t.references :partner, null: false, foreign_key: true
      t.references :partner_client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
