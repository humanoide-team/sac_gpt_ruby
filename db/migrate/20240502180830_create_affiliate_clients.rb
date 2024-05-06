class CreateAffiliateClients < ActiveRecord::Migration[6.1]
  def change
    create_table :affiliate_clients do |t|
      t.references :affiliate, null: false, foreign_key: true
      t.string :name
      t.string :phone
      t.string :email
      t.boolean :blocked, default: false

      t.timestamps
    end
  end
end
