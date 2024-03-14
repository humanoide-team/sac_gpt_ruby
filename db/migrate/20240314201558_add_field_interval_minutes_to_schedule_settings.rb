class AddFieldIntervalMinutesToScheduleSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :schedule_settings, :interval_minutes, :integer
  end
end
