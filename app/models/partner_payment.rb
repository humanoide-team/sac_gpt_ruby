class PartnerPayment < ApplicationRecord
  belongs_to :partner
  belongs_to :credit_card
end
