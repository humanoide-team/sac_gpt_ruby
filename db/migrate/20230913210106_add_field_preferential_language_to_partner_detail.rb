class AddFieldPreferentialLanguageToPartnerDetail < ActiveRecord::Migration[6.1]
  def change
    add_column :partner_details, :preferential_language, :string
  end
end
