class CreatePayments < ActiveRecord::Migration[6.1]
  def change
    create_table :payments do |t|
      t.integer :galax_pay_id
      t.string :galax_pay_my_id
      t.string :galax_pay_plan_my_id
      t.integer :plan_galax_pay_id
      t.integer :main_payment_method_id
      t.string :payment_link
      t.integer :value
      t.string :additional_info
      t.integer :status
      t.references :partner, null: false, foreign_key: true
      t.references :credit_card, null: false, foreign_key: true

      t.timestamps
    end
  end
end
