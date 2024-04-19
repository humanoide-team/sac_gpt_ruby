class CreateAffiliates < ActiveRecord::Migration[6.1]
  def change
    create_table :affiliates do |t|
      t.string :name
      t.string :contact_number
      t.string :service_number
      t.string :email
      t.string :password
      t.string :document
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
