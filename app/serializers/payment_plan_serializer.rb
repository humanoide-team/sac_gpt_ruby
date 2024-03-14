class PaymentPlanSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :name, :periodicity, :quantity, :additional_info, :plan_price_payment, :plan_price_value, :cost_per_thousand_toukens, :disable, :created_at, :updated_at
end
