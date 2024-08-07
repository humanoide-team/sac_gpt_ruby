class PartnerClientLead < ApplicationRecord
  belongs_to :partner
  belongs_to :partner_client

  scope :by_partner_id, ->(partner_id) { where(partner_id: partner_id) }
  scope :by_partner, ->(partner) { where(partner: partner) }

  def increase_token_count(tokens)
    self.token_count += tokens
    save
  end

  def messages_count
    partner_client.partner_client_messages.count
  end
end
