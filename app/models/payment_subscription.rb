require 'securerandom'

class PaymentSubscription < ApplicationRecord
  belongs_to :partner
  belongs_to :credit_card
  belongs_to :payment_plan

  before_create :create_galax_pay_payment_subscription

  before_destroy :cancel_galax_pay_payment_subscription

  enum main_payment_method_id: {
    creditcard: 0
  }

  enum status: {
    active: 0,
    canceled: 1,
    closed: 2,
    stopped: 3
  }

  def create_galax_pay_payment_subscription
    uuid = SecureRandom.uuid

    galax_pay_payment_subscription = GalaxPayClient.create_payment_subscription(uuid, payment_plan.galax_pay_my_id, first_pay_day_date, additional_info,
                                                          main_payment_method_id, partner, credit_card.galax_pay_my_id)

    if galax_pay_payment_subscription.nil?
      errors.add(:base, 'Erro ao criar Inscricao')
      throw :abort
    else
      self.galax_pay_id = galax_pay_payment_subscription['galaxPayId'].to_i
      self.status = galax_pay_payment_subscription['status']
      self.payment_link = galax_pay_payment_subscription['paymentLink']
      self.galax_pay_my_id = galax_pay_payment_subscription['myId']
    end
  end

  def cancel_galax_pay_payment_subscription
    response = GalaxPayClient.cancel_payment_subscription(galax_pay_id)

    return unless response == true

    update_attribute(:status, 'canceled')
  end
end
