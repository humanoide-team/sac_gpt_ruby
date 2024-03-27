class PartnerClient < ApplicationRecord

  belongs_to :partner
  has_one :conversation_thread, dependent: :destroy
  has_many :partner_client_messages, dependent: :destroy
  has_many :partner_client_leads, dependent: :destroy
  has_many :partner_client_conversation_infos, dependent: :destroy
  has_many :schedules, dependent: :destroy
  has_many :token_usages, dependent: :destroy
end

