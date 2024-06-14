class ExtraToken < ApplicationRecord
  belongs_to :partner
  belongs_to :payment

  after_create :increase_extra_token_count

  def increase_extra_token_count
    partner.current_mothly_history.increase_extra_token_count(token_quantity)
  end
end
