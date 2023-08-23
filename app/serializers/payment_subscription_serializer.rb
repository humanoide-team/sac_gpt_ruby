class PaymentSubscriptionSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :first_pay_day_date, :additional_info, :main_payment_method_id, :additional_info, :credit_card_id,
             :payment_plan_id, :status, :payment_link, :galax_pay_id, :galax_pay_my_id, :created_at, :updated_at
end
