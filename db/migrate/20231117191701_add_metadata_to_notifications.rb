class AddMetadataToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :metadata, :text
  end
end
