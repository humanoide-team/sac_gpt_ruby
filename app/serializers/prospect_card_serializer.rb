class ProspectCardSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :name, :phone, :email, :observations

  attribute :partner_linked, &:partner_linked
end
