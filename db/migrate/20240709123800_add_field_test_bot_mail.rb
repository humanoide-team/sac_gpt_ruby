class AddFieldTestBotMail < ActiveRecord::Migration[6.1]
  def change
    add_column :partner_test_bot_leads, :test_bot_mail, :string
  end
end
