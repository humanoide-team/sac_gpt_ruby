class AddFieldinstanceKeyToAffiliates < ActiveRecord::Migration[6.1]
  def change
    add_column :affiliates, :instance_key, :string
  end
end
