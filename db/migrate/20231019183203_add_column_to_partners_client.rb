class AddColumnToPartnersClient < ActiveRecord::Migration[6.1]
  def change
    add_column :partner_clients, :email, :string
  end
end
