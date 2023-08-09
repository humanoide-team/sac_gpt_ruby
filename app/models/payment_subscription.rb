class PaymentSubscription < ApplicationRecord
  belongs_to :partner
  belongs_to :credit_card
  belongs_to :payment_plan

  after_create :create_galax_pay_payment_subscription

  enum main_payment_method_id: {
    creditcard: 0
  }

  def create_galax_pay_payment_subscription
    # PaymentSubscription.create(first_pay_day_date: '2023-09-08', additional_info: 'teste subscription', main_payment_method_id: 'creditcard', partner_id: 1, credit_card_id:  12, payment_plan_id: 1)
    galax_pay_id = GalaxPayClient.create_payment_subscription(id, payment_plan.id, first_pay_day_date, additional_info, main_payment_method_id, partner, credit_card.id )
    update_attribute(:galax_pay_id, galax_pay_id)
  end

end
