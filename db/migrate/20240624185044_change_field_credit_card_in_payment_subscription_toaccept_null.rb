class ChangeFieldCreditCardInPaymentSubscriptionToacceptNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :payment_subscription, :credit_card_id, true
  end
end
