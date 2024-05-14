class AddFieldToAffiliate < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliates, :revenue_percentage, :integer, default: 10
  end
end
