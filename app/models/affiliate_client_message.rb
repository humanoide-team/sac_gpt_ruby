class AffiliateClientMessage < ApplicationRecord
  belongs_to :affiliate
  belongs_to :affiliate_client

  scope :by_affiliate_id, ->(affiliate_id) { where(affiliate_id:) }
  scope :by_affiliate, ->(affiliate) { where(affiliate:) }
end
