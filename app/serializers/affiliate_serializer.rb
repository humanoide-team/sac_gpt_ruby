class AffiliateSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :name, :email, :service_number, :contact_number, :document, :active, :created_at, :updated_at
  attributes :auth_token, :expires_at, if: proc { |record| record.auth_token.present? }

  attribute :affiliate_url do |object|
    object.generate_unique_url
  end
end
