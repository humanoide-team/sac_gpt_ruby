class AddFieldsToProspectCard < ActiveRecord::Migration[6.1]
  def change
    add_column :prospect_cards, :test_active, :boolean
  end
end
