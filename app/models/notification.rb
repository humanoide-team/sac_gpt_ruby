class Notification < ApplicationRecord
  belongs_to :partner

  enum notification_type: {
    new_lead_received: 0
  }
end
