require 'securerandom'

class AffiliatePayment < ApplicationRecord
  belongs_to :affiliate
  belongs_to :affiliate_credit_card

  before_create :create_galax_pay_payment

  accepts_nested_attributes_for :affiliate_extra_token, reject_if: :all_blank

  enum main_payment_method_id: {
    creditcard: 0
  }

  enum status: {
    active: 0,
    canceled: 1,
    closed: 2,
    stopped: 3,
    waitingPayment: 4,
    inactive: 5
  }

  def create_galax_pay_payment
    uuid = SecureRandom.uuid

    galax_pay_payment = GalaxPayClient.create_payment(uuid, payday, additional_info, main_payment_method_id,
      affiliate_credit_card.galax_pay_my_id, value, affiliate)

    if galax_pay_payment.nil?
      errors.add(:base, 'Erro ao criar pagamento, verifique os dados')
      throw :abort
    else
      self.galax_pay_id = galax_pay_payment['galaxPayId'].to_i
      self.galax_pay_my_id = galax_pay_payment['myId']
      self.galax_pay_plan_my_id = galax_pay_payment['planMyId']
      self.plan_galax_pay_id = galax_pay_payment['planGalaxPayId']
      self.payment_link = galax_pay_payment['paymentLink']
      self.status = galax_pay_payment['status']
    end
  end
end