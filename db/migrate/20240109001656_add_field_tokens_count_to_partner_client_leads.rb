class AddFieldTokensCountToPartnerClientLeads < ActiveRecord::Migration[6.1]
  def change
    add_column :partner_client_leads, :token_count, :integer
  end
end
