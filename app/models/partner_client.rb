class PartnerClient < ApplicationRecord

  has_many :partner_client_messages, dependent: :destroy
end
