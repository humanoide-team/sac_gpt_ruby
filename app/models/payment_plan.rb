class PaymentPlan < ApplicationRecord
  after_create :create_galax_pay_payment_plan

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
    # PaymentPlan.create(name: "Teste Plan", periodicity: "monthly", quantity: 12, additional_info: "esse e um teste", plan_price_payment: "creditcard", plan_price_value: 123456)
    galax_pay_id = GalaxPayClient.create_payment_plan(id, name, periodicity, quantity, additional_info, plan_price_payment, plan_price_value )
    update_attribute(:galax_pay_id, galax_pay_id)
  end
end
