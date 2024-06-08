class CreateAffiliateClientMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :affiliate_client_messages do |t|
      t.references :affiliate, null: false, foreign_key: true
      t.references :affiliate_client, null: false, foreign_key: true
      t.references :conversation_thread, null: true, foreign_key: true
      t.text :message
      t.text :automatic_response
      t.string :webhook_uuid
      t.string :open_ai_message_id

      t.timestamps
    end
  end
end
