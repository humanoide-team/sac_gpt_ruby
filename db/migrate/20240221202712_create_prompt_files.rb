class CreatePromptFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :prompt_files do |t|
      t.string :open_ai_file_id
      t.references :partner_detail, null: false, foreign_key: true
      t.references :partner_assistent, null: false, foreign_key: true

      t.timestamps
    end
  end
end
