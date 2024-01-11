class AddFieldMaxTokenCountToPaymentSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :payment_subscriptions, :max_token_count, :integer, default: 0
  end
end
