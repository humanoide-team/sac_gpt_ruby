class ScheduleSettingSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :google_agenda_id, :duration_in_minutes, :week_days, :start_time, :end_time, :created_at, :updated_at
end
