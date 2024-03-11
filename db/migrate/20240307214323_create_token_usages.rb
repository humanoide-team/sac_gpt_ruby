class CreateTokenUsages < ActiveRecord::Migration[6.1]
  def change
    create_table :token_usages do |t|
      t.references :partner_client, null: false, foreign_key: true
      t.string :model
      t.integer :prompt_tokens, default: 0
      t.integer :completion_tokens, default: 0
      t.integer :total_tokens, default: 0

      t.timestamps
    end
  end
end
