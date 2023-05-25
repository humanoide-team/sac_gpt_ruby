class PartnerDetailSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :name_attendant, :company_name, :company_niche, :served_region, :company_products, :company_contact,
             :company_objective, :created_at, :updated_at
end
