class AddFieldsToPartner < ActiveRecord::Migration[6.1]
  def change
    add_column :partners, :wpp_connected, :boolean, default: true
    add_column :partners, :last_callback_receive, :datetime
    add_column :partners, :remote_jid, :string
  end
end
