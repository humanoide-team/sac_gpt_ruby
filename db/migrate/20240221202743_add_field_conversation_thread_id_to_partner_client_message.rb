class AddFieldConversationThreadIdToPartnerClientMessage < ActiveRecord::Migration[6.1]
  def change
    add_reference :partner_client_messages, :conversation_thread, null: true, foreign_key: true
    add_column :partner_client_messages, :open_ai_message_id, :string
  end
end
