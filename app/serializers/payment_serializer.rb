class PaymentSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :id, :galax_pay_id, :galax_pay_my_id, :galax_pay_plan_my_id, :plan_galax_pay_id, :main_payment_method_id,
             :payment_link, :value, :additional_info, :status, :credit_card_id, :created_at, :updated_at,
             :payday
end
