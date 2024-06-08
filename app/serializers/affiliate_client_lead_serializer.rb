class AffiliateClientLeadSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :affiliate, :affiliate_client, :lead_classification, :conversation_summary, :lead_score, :token_count, :created_at, :updated_at
end