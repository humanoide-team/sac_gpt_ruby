class AddFieldBlockedInPartnerClient < ActiveRecord::Migration[6.1]
  def change
    add_column :partner_clients, :blocked, :boolean, default: false
  end
end
