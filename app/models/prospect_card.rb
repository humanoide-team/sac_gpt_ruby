class ProspectCard < ApplicationRecord
  has_one :prospect_detail, dependent: :destroy
  belongs_to :affiliate

  accepts_nested_attributes_for :prospect_detail, reject_if: :all_blank

  def partner_linked
    !affiliate.partners.find_by(email: email).nil?
  end
end
