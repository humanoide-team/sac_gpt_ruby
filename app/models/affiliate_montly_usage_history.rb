class AffiliateMontlyUsageHistory < ApplicationRecord
  belongs_to :affiliate

  def increase_token_count(tokens)
    self.token_count += tokens
    save
  end

  def increase_extra_token_count(tokens)
    self.extra_token_count += tokens
    save
  end

  def subtract_tokens(amount)
    if self.token_count.positive?
      self.token_count -= amount
      self.token_count = 0 if self.token_count.negative?
    elsif self.token_count.zero? && self.extra_token_count.positive?
      self.extra_token_count -= amount
      self.extra_token_count = 0 if self.extra_token_count.negative?
    end
    save
  end
end
