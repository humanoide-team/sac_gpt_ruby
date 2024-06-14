class CreateAffiliateExtraTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :affiliate_extra_tokens do |t|
      t.integer :token_quantity
      t.references :affiliate, null: false, foreign_key: true
      t.references :affiliate_payment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
