class AffiliateClientLead < ApplicationRecord
  belongs_to :affiliate
  belongs_to :affiliate_client

  scope :by_affiliate_id, ->(affiliate_id) { where(affiliate_id: affiliate_id) }
  scope :by_affiliate, ->(affiliate) { where(affiliate: affiliate) }

  def increase_token_count(tokens)
    self.token_count += tokens
    save
  end
end
