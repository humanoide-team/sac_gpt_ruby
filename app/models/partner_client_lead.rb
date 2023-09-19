class PartnerClientLead < ApplicationRecord
  belongs_to :partner
  belongs_to :partner_client

  scope :by_partner_id, ->(partner_id) { where(partner_id: partner_id) }
  scope :by_partner, ->(partner) { where(partner: partner) }
end
