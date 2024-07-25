class AffiliateTestBotLeadSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :lead_classification, :conversation_summary, :lead_score, :token_count, :created_at, :updated_at

  attribute :messages_count do |object|
    object.affiliate.affiliate_test_bot_messages.count
  end
end
