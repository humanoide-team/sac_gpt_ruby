class PartnerCompleteSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :name, :email, :phone, :partner_detail, :created_at, :updated_at

end