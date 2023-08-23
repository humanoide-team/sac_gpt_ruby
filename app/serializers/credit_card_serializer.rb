class CreditCardSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :galax_pay_id, :number, :expires_at, :holder_name, :created_at, :updated_at
end
