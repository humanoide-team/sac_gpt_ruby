require 'securerandom'

class AffiliateCreditCard < ApplicationRecord
  belongs_to :affiliate

  before_create :create_galax_pay_credit_card
  before_create :set_all_credit_card_default_false

  attr_accessor :card_number, :card_holder_name, :card_cvv

  def create_galax_pay_credit_card
    uuid = SecureRandom.uuid

    galax_pay_credit_card = GalaxPayClient.create_client_payment_card(uuid, card_number, card_holder_name, expires_at,
                                                                      card_cvv, affiliate.galax_pay_id)
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

  def set_all_credit_card_default_false
    return unless default && default_changed?

    affiliate.affiliate_credit_cards.where(default: true).update(default: false)
  end

  def mask_credit_card_number
    number.gsub(/.(?=....)/, '*')
  end
end
