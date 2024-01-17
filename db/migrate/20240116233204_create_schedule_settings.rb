class CreateScheduleSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :schedule_settings do |t|
      t.integer :duration_in_minutes
      t.string :week_days
      t.string :start_time
      t.string :end_time
      t.string :google_agenda_id
      t.references :partner, null: false, foreign_key: true

      t.timestamps
    end
  end
end
