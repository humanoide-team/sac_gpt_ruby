class PartnerClientLeadSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :partner, :partner_client, :lead_classification, :conversation_summary, :lead_score, :created_at, :updated_at
end
