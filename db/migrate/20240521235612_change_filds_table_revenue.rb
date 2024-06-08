class ChangeFildsTableRevenue < ActiveRecord::Migration[6.1]
  def change
    add_reference :revenues, :partner_transaction, polymorphic: true, null: true
    remove_column :revenues, :payment_id
  end
end
