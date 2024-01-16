class Notification < ApplicationRecord
  belongs_to :partner
  serialize :metadata, JSON

  enum notification_type: {
    new_lead_received: 0,
    welcome_partner: 1,
    subscription_confirmation: 2,
    cancellation_plan: 3,
    alert_exchange_card: 4,
    payment_confirmation: 5,
  }
end
