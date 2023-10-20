class NotificationSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :title, :description, :readed, :created_at, :updated_at
end
