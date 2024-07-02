class CreatePartnerTestBotLeads < ActiveRecord::Migration[6.1]
  def change
    create_table :partner_test_bot_leads do |t|
      t.references :partner, null: false, foreign_key: true
      t.text :conversation_summary
      t.text :lead_classification
      t.integer :lead_score, default: 0
      t.integer :token_count, default: 0

      t.timestamps
    end
  end
end
