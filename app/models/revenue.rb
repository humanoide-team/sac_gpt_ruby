class Revenue < ApplicationRecord
  belongs_to :partner
  belongs_to :affiliate
  belongs_to :payment
end
