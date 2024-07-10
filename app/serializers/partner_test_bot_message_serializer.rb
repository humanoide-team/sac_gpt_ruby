class PartnerTestBotMessageSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :message, :automatic_response, :read, :created_at, :updated_at
end
