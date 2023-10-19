class AddColumnsToPartners < ActiveRecord::Migration[6.1]
  def change
    add_column :partners, :calendar_token, :string
  end
end
