class ProspectCardSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :name,:company_name, :phone, :email, :observations, :status, :prospect_detail

  attribute :partner_linked do |o|
    o.partner_linked
  end
end
