class CreatePaymentPlans < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_plans do |t|
      t.string :name
      t.integer :periodicity
      t.integer :quantity
      t.string :additional_info
      t.integer :plan_price_payment
      t.string :plan_price_value
      t.integer :galax_pay_id

      t.timestamps
    end
  end
end
