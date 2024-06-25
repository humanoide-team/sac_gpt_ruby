class CreateAffiliateMontlyUsageHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :affiliate_montly_usage_histories do |t|
      t.references :affiliate, null: false, foreign_key: true
      t.date :period
      t.integer :token_count, default: 0
      t.integer :extra_token_count, default: 0
      t.boolean :exceed_mail, default: false
      t.boolean :exceed_extra_token_mail, default: false

      t.timestamps
    end
  end
end
