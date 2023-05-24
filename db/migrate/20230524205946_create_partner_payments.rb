class CreatePartnerPayments < ActiveRecord::Migration[6.1]
  def change
    create_table :partner_payments do |t|
      t.references :partner, null: false, foreign_key: true
      t.references :credit_card, null: false, foreign_key: true
      t.string :status
      t.string :pagarme_transaction
      t.string :amount

      t.timestamps
    end
  end
end
