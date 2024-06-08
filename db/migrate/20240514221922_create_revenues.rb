class CreateRevenues < ActiveRecord::Migration[6.1]
  def change
    create_table :revenues do |t|
      t.references :affiliate, null: false, foreign_key: true
      t.references :payment, null: false, foreign_key: true
      t.references :partner, null: false, foreign_key: true
      t.integer :value, default: 0
      t.timestamps
    end
  end
end
