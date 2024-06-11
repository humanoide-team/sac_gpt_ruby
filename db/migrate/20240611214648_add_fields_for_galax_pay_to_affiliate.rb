class AddFieldsForGalaxPayToAffiliate < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliates, :galax_pay_id, :integer
    add_column :affiliates, :galax_pay_my_id, :string
  end
end
