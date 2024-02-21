class AddFieldPartnerIdToPartnerClient < ActiveRecord::Migration[6.1]
  def change
    add_reference :partner_clients, :partner, null: true, foreign_key: true
  end
end
