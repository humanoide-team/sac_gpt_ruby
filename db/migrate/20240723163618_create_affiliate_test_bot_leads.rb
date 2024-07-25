class CreateAffiliateTestBotLeads < ActiveRecord::Migration[6.1]
  def change
    create_table :affiliate_test_bot_leads do |t|
      t.references :affiliate, null: false, foreign_key: true
      t.text :conversation_summary
      t.text :lead_classification
      t.integer :lead_score, default: 0
      t.integer :token_count, default: 0
      t.string :test_bot_mail

      t.timestamps
    end
  end
end
