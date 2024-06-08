class PartnerAdminShortSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :name, :email, :service_number, :contact_number, :document, :partner_detail, :active, :current_plan, :created_at, :updated_at

  attribute :current_plan do |o|
    o.current_plan
  end
end
