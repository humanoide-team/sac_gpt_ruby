class CreateAffiliateClientConversationInfos < ActiveRecord::Migration[6.1]
  def change
    create_table :affiliate_client_conversation_infos do |t|
      t.references :affiliate, null: false, foreign_key: true, index: { name: 'index_affiliate_client_convo_infos_on_affiliate_id' }
      t.references :affiliate_client, null: false, foreign_key: true, index: { name: 'index_affiliate_client_convo_infos_on_aff_client_id' }
      t.text :system_conversation_resume

      t.timestamps
    end
  end
end
