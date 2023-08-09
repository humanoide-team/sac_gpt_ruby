class AddFieldsToPaymentSubscription < ActiveRecord::Migration[6.1]
  def change
    add_column :payment_subscriptions, :status, :integer
    add_column :payment_subscriptions, :payment_link, :string
  end
end
