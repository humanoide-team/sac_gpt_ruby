class AddFieldsToAffiliate < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliates, :deleted_at, :datetime
    add_column :affiliates, :slug, :string
    add_column :affiliates, :encrypted_password, :string, null: false, default: ""
    add_column :affiliates, :reset_password_token, :string, null: false, default: ""
    add_column :affiliates, :reset_password_sent_at, :datetime
    add_column :affiliates, :remember_created_at, :datetime
  end
end
