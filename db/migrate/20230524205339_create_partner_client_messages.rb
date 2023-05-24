class CreatePartnerClientMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :partner_client_messages do |t|
      t.references :partner, null: false, foreign_key: true
      t.references :partner_client, null: false, foreign_key: true
      t.text :message
      t.text :automatic_response

      t.timestamps
    end
  end
end
