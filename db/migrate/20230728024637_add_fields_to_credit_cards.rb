class AddFieldsToCreditCards < ActiveRecord::Migration[6.1]
  def change
    add_column :credit_cards, :number, :string
    add_column :credit_cards, :expires_at, :string
    add_column :credit_cards, :galax_pay_id, :integer
    add_column :credit_cards, :galax_pay_my_id, :string
    add_column :credit_cards, :default, :boolean
    remove_column :credit_cards, :last_digits
    remove_column :credit_cards, :first_digits
    remove_column :credit_cards, :pagarme_card_id
    remove_column :credit_cards, :pagarme_subscription_id
  end
end
