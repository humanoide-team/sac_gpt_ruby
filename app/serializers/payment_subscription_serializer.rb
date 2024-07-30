class PaymentSubscriptionSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :first_pay_day_date, :additional_info, :main_payment_method_id, :additional_info, :credit_card_id,
             :payment_plan, :status, :payment_link, :galax_pay_id, :galax_pay_my_id, :created_at, :updated_at

             attribute :expiration_date do |object|
              if object.payment_plan.name == 'Plano Gratuito'
                'Plano sem expiração'
              else
                object.next_payment_day
              end
            end
end
