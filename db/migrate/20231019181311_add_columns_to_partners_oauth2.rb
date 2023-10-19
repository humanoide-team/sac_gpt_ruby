class AddColumnsToPartnersOauth2 < ActiveRecord::Migration[6.1]
  def change
    add_column :partners, :access_token, :string
    add_column :partners, :expires_at, :datetime
    add_column :partners, :refresh_token, :string
  end
end
