class CreateAffiliateCreditCards < ActiveRecord::Migration[6.1]
  def change
    create_table :affiliate_credit_cards do |t|
      t.references :affiliate, null: false, foreign_key: true
      t.string :brand
      t.string :holder_name
      t.string :number
      t.string :expires_at
      t.integer :galax_pay_id
      t.string :galax_pay_my_id
      t.boolean :default

      t.timestamps
    end
  end
end
