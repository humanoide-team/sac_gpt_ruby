require 'securerandom'

class Payment < ApplicationRecord
  belongs_to :partner
  belongs_to :credit_card
  has_one :extra_token, dependent: :destroy
  has_many :revenue, as: :partner_transaction, dependent: :delete_all

  before_create :create_galax_pay_payment

  after_create :payment_confirmation_mail

  after_create :create_affiliate_revenue

  accepts_nested_attributes_for :extra_token, reject_if: :all_blank

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
                                                      credit_card.galax_pay_my_id, value, partner)

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

  def payment_confirmation_mail
    PaymentMailer._send_payment_confirmation_mail(self, partner, credit_card).deliver
    partner.notifications.create(
      title: 'Confirmação de Pagamento',
      description: 'Seu pagamento foi confirmado!',
      notification_type: :payment_confirmation,
      metadata: {
        payment: id
      }
    )
  end

  def create_affiliate_revenue
    return if partner.affiliate.nil?

    Revenue.create(partner_transaction: self, partner:, affiliate: partner.affiliate, value: value * (partner.affiliate.revenue_percentage / 100.0))
  end
end
