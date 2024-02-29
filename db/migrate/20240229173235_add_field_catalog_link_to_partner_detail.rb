class AddFieldCatalogLinkToPartnerDetail < ActiveRecord::Migration[6.1]
  def change
    add_column :partner_details, :catalog_link, :string
  end
end
