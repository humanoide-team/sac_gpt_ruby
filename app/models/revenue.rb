class Revenue < ApplicationRecord
  belongs_to :partner
  belongs_to :affiliate
  belongs_to :partner_transaction, polymorphic: true

  after_create :increase_extra_token_count

  def increase_extra_token_count
    affiliate.current_mothly_history.increase_extra_token_count((affiliate.max_token_count * 0.05).to_i)
  end
end
