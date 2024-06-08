class AffiliateClient < ApplicationRecord
  belongs_to :affiliate
  has_many :affiliate_client_messages, dependent: :destroy
  has_many :affiliate_client_leads, dependent: :destroy
  has_many :affiliate_client_conversation_infos, dependent: :destroy
  has_many :token_usages, dependent: :destroy
end
