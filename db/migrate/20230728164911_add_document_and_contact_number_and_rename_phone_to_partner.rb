class AddDocumentAndContactNumberAndRenamePhoneToPartner < ActiveRecord::Migration[6.1]
  def change
    add_column :partners, :document, :string
    add_column :partners, :contact_number, :string
    rename_column :partners, :phone, :service_number
  end
end
