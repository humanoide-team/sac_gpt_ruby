require 'securerandom'

class CreditCard < ApplicationRecord
  belongs_to :partner

  before_create :create_galax_pay_credit_card
  before_create :set_all_credit_card_default_false

  after_create :change_subscription_payment_method
  has_one :payment_subscription, dependent: :destroy

  attr_accessor :card_number, :card_holder_name, :card_cvv

  def create_galax_pay_credit_card
    uuid = SecureRandom.uuid

    galax_pay_credit_card = GalaxPayClient.create_client_payment_card(uuid, card_number, card_holder_name, expires_at,
                                                                      card_cvv, partner.galax_pay_id)
    if galax_pay_credit_card.nil?
      errors.add(:base, 'Dados do cartão invalido')
      throw :abort
    else
      self.galax_pay_id = galax_pay_credit_card['galaxPayId']
      self.number = galax_pay_credit_card['number']
      self.expires_at = galax_pay_credit_card['expiresAt']
      self.holder_name = card_holder_name
      self.galax_pay_id = galax_pay_credit_card['galaxPayId']
      self.galax_pay_my_id = galax_pay_credit_card['myId']
      self.default = true
    end
  end

  def change_subscription_payment_method
    payment_subscriptions = partner.payment_subscriptions.where(status: :active)
    return if payment_subscriptions.empty?

    alert_exchange_card_mail if payment_subscriptions.first.edit_payment_method_galax_pay_payment_subscription(self)
  end

  def alert_exchange_card_mail
    PaymentPlanMailer._send_alert_exchange_card_mail(self, partner).deliver
    partner.notifications.create(
      title: 'Aviso de Troca de Cartão de Crédito no SacGPT',
      description: 'Recebemos uma atualização em relação ao método de pagamento associado à sua assinatura no SacGPT.',
      notification_type: :alert_exchange_card,
      metadata: {
        payment_subscription: id
      }
    )
  end

  def set_all_credit_card_default_false
    return unless default && default_changed?

    partner.credit_cards.where(default: true).update(default: false)
  end

  def mask_credit_card_number
    number.gsub(/.(?=....)/, '*')
  end

end
