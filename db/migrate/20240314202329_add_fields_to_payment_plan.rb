class AddFieldsToPaymentPlan < ActiveRecord::Migration[6.1]
  def change
    add_column :payment_plans, :disable, :boolean, default: false
    add_column :payment_plans, :cost_per_thousand_toukens, :integer
  end
end
