class CreateCreditCards < ActiveRecord::Migration[6.1]
  def change
    create_table :credit_cards do |t|
      t.references :partner, null: false, foreign_key: true
      t.string :first_digits
      t.string :last_digits
      t.string :brand
      t.string :holder_name
      t.string :pagarme_card_id
      t.string :pagarme_subscription_id

      t.timestamps
    end
  end
end
