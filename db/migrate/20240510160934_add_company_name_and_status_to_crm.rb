class AddCompanyNameAndStatusToCrm < ActiveRecord::Migration[6.1]
  def change
    add_column :prospect_cards, :company_name, :string
    add_column :prospect_cards, :status, :integer, default: 0
  end
end
