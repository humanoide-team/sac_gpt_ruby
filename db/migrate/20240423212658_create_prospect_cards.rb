class CreateProspectCards < ActiveRecord::Migration[6.1]
  def change
    create_table :prospect_cards do |t|
      t.references :affiliate, null: false, foreign_key: true
      t.string :name
      t.string :phone
      t.string :email
      t.string :observations

      t.timestamps
    end
  end
end
