class AddUuidToPartnerClientMessages < ActiveRecord::Migration[6.1]
  def change
    add_column :partner_client_messages, :webhook_uuid, :string
  end
end
