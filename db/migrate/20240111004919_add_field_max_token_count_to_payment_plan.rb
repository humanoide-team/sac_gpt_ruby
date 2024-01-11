class AddFieldMaxTokenCountToPaymentPlan < ActiveRecord::Migration[6.1]
  def change
    add_column :payment_plans, :max_token_count, :integer
  end
end
