class Notification < ApplicationRecord
  belongs_to :partner

  enum notification_type: {
    customer_service: 0
  }
end
