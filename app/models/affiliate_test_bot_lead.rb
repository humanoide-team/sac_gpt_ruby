class AffiliateTestBotLead < ApplicationRecord
  belongs_to :affiliate

  def increase_token_count(tokens)
    self.token_count += tokens
    save
  end

  def messages_count
    affiliate.affiliate_test_bot_messages.count
  end
end
