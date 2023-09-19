class PartnerDetailSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :name_attendant, :company_name, :company_niche, :served_region, :company_products, :company_services, :company_contact, :company_objective, :main_goals, :business_goals, :marketing_channels, :key_differentials, :target_audience, :tone_voice, :preferential_language, :created_at, :updated_at
end
