class PartnerClientMessage < ApplicationRecord
  belongs_to :partner
  belongs_to :partner_client
end
