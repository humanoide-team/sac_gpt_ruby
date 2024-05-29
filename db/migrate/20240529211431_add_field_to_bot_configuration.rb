class AddFieldToBotConfiguration < ActiveRecord::Migration[6.1]
  def change
    add_reference :bot_configurations, :prospect_card, null: true, foreign_key: true
  end
end
