class AdminSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :name, :email, :created_at, :updated_at
  attributes :auth_token, :expires_at, if: Proc.new { |record| record.auth_token.present? }

end