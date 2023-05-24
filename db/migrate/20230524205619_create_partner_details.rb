class CreatePartnerDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :partner_details do |t|
      t.references :partner, null: false, foreign_key: true
      t.string :about
      t.string :company
      t.string :service
      t.string :service_list
      t.string :product_list
      t.string :persona

      t.timestamps
    end
  end
end
