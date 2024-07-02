class CreatePartnerTestBotMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :partner_test_bot_messages do |t|
      t.references :partner, null: false, foreign_key: true
      t.text :message
      t.text :automatic_response
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
