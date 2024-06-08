class CreateAffiliateBankDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :affiliate_bank_details do |t|
      t.references :affiliate, null: false, foreign_key: true
      t.string :responsible
      t.string :document_number
      t.string :bank_code
      t.string :agency
      t.string :account
      t.integer :account_type, default: 0

      t.timestamps
    end
  end
end
