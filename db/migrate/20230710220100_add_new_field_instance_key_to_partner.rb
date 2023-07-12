class AddNewFieldInstanceKeyToPartner < ActiveRecord::Migration[6.1]
  def change
    add_column :partners, :instance_key, :string
  end
end
