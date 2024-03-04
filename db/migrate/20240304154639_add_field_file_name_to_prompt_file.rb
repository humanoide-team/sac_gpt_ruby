class AddFieldFileNameToPromptFile < ActiveRecord::Migration[6.1]
  def change
    add_column :prompt_files, :file_name, :string
  end
end
