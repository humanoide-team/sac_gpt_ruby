class PartnerClient < ApplicationRecord

  has_many :partner_client_messages, dependent: :destroy
  has_many :partner_client_leads, dependent: :destroy
  has_many :partner_client_conversation_infos, dependent: :destroy
  has_many :schedules, dependent: :destroy
end
