class CreateFaqItems < ActiveRecord::Migration[6.1]
  def change
    create_table :faq_items do |t|
      t.string :title
      t.string :body
      t.integer :sequence

      t.timestamps
    end
  end
end
