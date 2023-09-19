class RemoveColumnFromPartnerDetail < ActiveRecord::Migration[6.1]
  def change
    remove_column :partner_details, :week_days
    remove_column :partner_details, :meeting_hours
  end
end
