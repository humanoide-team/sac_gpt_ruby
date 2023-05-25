class PartnerClientSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :name, :phone, :created_at, :updated_at
end
