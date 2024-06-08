class AddFieldToBankDetail < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliate_bank_details, :pix_code, :string
  end
end
