class CreateExtraTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :extra_tokens do |t|
      t.integer :token_quantity
      t.references :partner, null: false, foreign_key: true
      t.references :payment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
