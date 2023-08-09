class AddFieldGalaxPaidIdToPartner < ActiveRecord::Migration[6.1]
  def change
    add_column :partners, :galax_pay_id, :integer
  end
end
