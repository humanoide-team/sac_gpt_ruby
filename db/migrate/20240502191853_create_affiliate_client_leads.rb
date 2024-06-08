class CreateAffiliateClientLeads < ActiveRecord::Migration[6.1]
  def change
    create_table :affiliate_client_leads do |t|
      t.references :affiliate, null: false, foreign_key: true
      t.references :affiliate_client, null: false, foreign_key: true
      t.text :conversation_summary
      t.text :lead_classification
      t.integer :lead_score
      t.integer :token_count, default: 0

      t.timestamps
    end
  end
end
