class AddPaydayToPayments < ActiveRecord::Migration[6.1]
  def change
    add_column :payments, :payday, :date
  end
end
