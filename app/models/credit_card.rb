require 'securerandom'

class CreditCard < ApplicationRecord
  belongs_to :partner

  before_create :create_galax_pay_credit_card
  after_create :alert_exchange_card_mail

  attr_accessor :card_number, :card_holder_name, :card_cvv

  def create_galax_pay_credit_card
    uuid = SecureRandom.uuid

    galax_pay_credit_card = GalaxPayClient.create_client_payment_card(uuid, card_number, card_holder_name, expires_at, card_cvv, partner.galax_pay_id)
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

  def alert_exchange_card_mail
    PaymentPlanMailer._send_alert_exchange_card_mail(self, partner).deliver
  end
end
