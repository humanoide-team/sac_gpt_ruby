class CreatePaymentSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :payment_subscriptions do |t|
      t.date :first_pay_day_date
      t.string :additional_info
      t.integer :main_payment_method_id
      t.references :partner, null: false, foreign_key: true
      t.references :credit_card, null: false, foreign_key: true
      t.references :payment_plan, null: false, foreign_key: true
      t.integer :galax_pay_id

      t.timestamps
    end
  end
end
