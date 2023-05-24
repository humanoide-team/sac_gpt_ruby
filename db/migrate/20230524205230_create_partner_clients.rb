class CreatePartnerClients < ActiveRecord::Migration[6.1]
  def change
    create_table :partner_clients do |t|
      t.string :name
      t.string :phone

      t.timestamps
    end
  end
end
