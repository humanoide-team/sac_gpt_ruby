class AddFieldCompanyNameToPartner < ActiveRecord::Migration[6.1]
  def change
    add_column :partners, :company_name, :string
  end
end
