class CreatePartnerClientConversationInfos < ActiveRecord::Migration[6.1]
  def change
    create_table :partner_client_conversation_infos do |t|
      t.references :partner, null: false, foreign_key: true
      t.references :partner_client, null: false, foreign_key: true
      t.text :system_conversation_resume

      t.timestamps
    end
  end
end
