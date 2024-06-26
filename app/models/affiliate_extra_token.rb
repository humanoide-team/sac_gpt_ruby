class AffiliateExtraToken < ApplicationRecord
  belongs_to :affiliate
  belongs_to :affiliate_payment

  after_create :increase_extra_token_count

  def increase_extra_token_count
    return unless affiliate_payment.status == 'active'

    affiliate.current_mothly_history.increase_extra_token_count(token_quantity)
  end
end
