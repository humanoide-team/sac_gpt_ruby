class CreateMontlyUsageHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :montly_usage_histories do |t|
      t.date :period
      t.integer :token_count, default: 0
      t.references :partner, null: false, foreign_key: true

      t.timestamps
    end
  end
end
