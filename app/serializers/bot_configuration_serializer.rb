class BotConfigurationSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :affiliate_id, :prospect_card, :about, :service, :persona, :name_attendant, :company_name, :company_niche, :served_region,
             :company_services, :company_products, :company_contact, :company_objectives, :marketing_channels,
             :key_differentials, :tone_voice, :preferential_language, :catalog_link, :token_count, :created_at, :updated_at
end
