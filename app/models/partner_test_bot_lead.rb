class PartnerTestBotLead < ApplicationRecord
  belongs_to :partner

  def increase_token_count(tokens)
    self.token_count += tokens
    save
  end

  def messages_count
    partner.partner_test_bot_messages.count
  end
end
