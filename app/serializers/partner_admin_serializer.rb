class PartnerAdminSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :name, :email, :phone, :partner_detail, :partner_clients, :created_at, :updated_at

  attribute :partner_clients do |o|
    o.partner_clients.uniq.sort_by(&:id).map do |partner_client|
      {
        id: partner_client.id,
        name: partner_client.name,
        phone: partner_client.phone
      }
    end
  end
end