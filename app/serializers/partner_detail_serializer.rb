class PartnerDetailSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :name_attendant, :company_name, :company_niche, :served_region, :company_products, :company_services,
             :company_contact, :company_objectives, :marketing_channels, :key_differentials,
             :tone_voice, :preferential_language, :catalog_link, :twitter_x_link, :youtube_link, :facebook_link, :instagram_link, 
             :connected_with_google, :created_at, :updated_at

  attribute :connected_with_google do |o|
    o.partner.connected_with_google
  end
end
