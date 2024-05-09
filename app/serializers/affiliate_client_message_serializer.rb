class AffiliateClientMessageSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :affiliate, :affiliate_client, :message, :automatic_response, :created_at, :updated_at

end