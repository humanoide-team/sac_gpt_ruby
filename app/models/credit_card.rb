class CreditCard < ApplicationRecord
  belongs_to :partner

  after_create :create_galax_pay_credit_card

  def create_galax_pay_credit_card()
    # Partner.last.credit_cards.create(number: "4111 1111 1111 1111", holder: "JOAO J J DA SILVA", expires_at: "2031-07", cvv: "363")
    galax_pay_id = GalaxPayClient.create_client_payment_card(id, number, holder, expires_at, cvv, partner.galax_pay_id)
    update_attribute(:galax_pay_id, galax_pay_id)
  end
end
