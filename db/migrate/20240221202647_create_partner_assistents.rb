class CreatePartnerAssistents < ActiveRecord::Migration[6.1]
  def change
    create_table :partner_assistents do |t|
      t.string :open_ai_assistent_id
      t.references :partner, null: false, foreign_key: true

      t.timestamps
    end
  end
end
