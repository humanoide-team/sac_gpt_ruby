class AddWppFieldsToAffiliate < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliates, :wpp_connected, :boolean, default: true
    add_column :affiliates, :last_callback_receive, :datetime
  end
end
