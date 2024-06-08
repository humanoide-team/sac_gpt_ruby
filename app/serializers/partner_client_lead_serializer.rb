class PartnerClientLeadSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :partner, :partner_client, :lead_classification, :conversation_summary, :lead_score, :token_count, :created_at, :updated_at

  attribute :messages_count do |object|
    object.messages_count
  end
end
