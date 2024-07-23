class AddPopUpToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :pop_up, :boolean, default: false
  end
end
