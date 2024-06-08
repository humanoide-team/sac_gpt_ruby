class CreateProspectDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :prospect_details do |t|
      t.references :prospect_card, null: false, foreign_key: true
      t.string :about
      t.string :service
      t.string :persona
      t.string :name_attendant
      t.string :company_name
      t.string :company_niche
      t.string :served_region
      t.string :company_services
      t.string :company_products
      t.string :company_contact
      t.string :company_objectives, default: [], array: true
      t.string :marketing_channels
      t.string :key_differentials
      t.string :tone_voice, default: [], array: true
      t.string :preferential_language
      t.string :catalog_link
      t.integer :token_count, default: 0

      t.timestamps
    end
  end
end
