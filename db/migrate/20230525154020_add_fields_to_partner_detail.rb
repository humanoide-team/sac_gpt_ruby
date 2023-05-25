class AddFieldsToPartnerDetail < ActiveRecord::Migration[6.1]
  def change
    add_column :partner_details, :name_attendant, :string
    add_column :partner_details, :company_name, :string
    add_column :partner_details, :company_niche, :string
    add_column :partner_details, :served_region, :string
    add_column :partner_details, :company_services, :string
    add_column :partner_details, :company_products, :string
    add_column :partner_details, :company_contact, :string
    add_column :partner_details, :company_objective, :string
  end
end
