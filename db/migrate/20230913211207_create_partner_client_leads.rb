class CreatePartnerClientLeads < ActiveRecord::Migration[6.1]
  def change
    create_table :partner_client_leads do |t|
      t.references :partner, null: false, foreign_key: true
      t.references :partner_client, null: false, foreign_key: true
      t.text :conversation_summary
      t.text :lead_classification
      t.integer :lead_score

      t.timestamps
    end
  end
end
