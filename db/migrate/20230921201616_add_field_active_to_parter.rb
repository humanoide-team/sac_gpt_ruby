class AddFieldActiveToParter < ActiveRecord::Migration[6.1]
  def change
    add_column :partners, :active, :boolean, default: false
  end
end
