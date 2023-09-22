require 'securerandom'

class PaymentPlan < ApplicationRecord
  before_create :create_galax_pay_payment_plan

  enum periodicity: {
    weekly: 0,
    biweekly: 1,
    monthly: 2,
    bimonthly: 3,
    quarterly: 4,
    biannual: 5,
    yearly: 6
  }

  enum plan_price_payment: {
    creditcard: 0
  }

  def create_galax_pay_payment_plan
    uuid = SecureRandom.uuid

    galax_pay_payment_plan = GalaxPayClient.create_payment_plan(uuid, name, periodicity, quantity, additional_info, plan_price_payment, plan_price_value )

    if galax_pay_payment_plan.nil?
      errors.add(:base, 'Erro ao criar Plano de pagamento')
      throw :abort
    else
      self.galax_pay_id = galax_pay_payment_plan['galaxPayId'].to_i
      self.galax_pay_my_id = galax_pay_payment_plan['myId']

      send_subscription_confirmation_mail
    end
  end

end
