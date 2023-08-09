class AddFieldsToCreditCards < ActiveRecord::Migration[6.1]
  def change
    add_column :credit_cards, :number, :string
    add_column :credit_cards, :holder, :string
    add_column :credit_cards, :expires_at, :string
    add_column :credit_cards, :cvv, :string
    add_column :credit_cards, :galax_pay_id, :string
  end
end
