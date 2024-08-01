class NotificationSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :title, :description, :pop_up, :readed, :created_at, :updated_at, :metadata
end
