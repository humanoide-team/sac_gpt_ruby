class AddFieldActiveToParter < ActiveRecord::Migration[6.1]
  def change
    add_column :parters, :active, :boolean, default: false
  end
end
