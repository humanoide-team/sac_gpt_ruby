class Notification < ApplicationRecord
  belongs_to :partner
  serialize :metadata, JSON

  enum notification_type: {
    new_lead_received: 0
  }
end
