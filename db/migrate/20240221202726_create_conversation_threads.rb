class CreateConversationThreads < ActiveRecord::Migration[6.1]
  def change
    create_table :conversation_threads do |t|
      t.string :open_ai_thread_id
      t.references :partner, null: false, foreign_key: true
      t.references :partner_client, null: false, foreign_key: true
      t.references :partner_assistent, null: false, foreign_key: true

      t.timestamps
    end
  end
end
