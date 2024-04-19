class AddFieldAffilieateIdToPartner < ActiveRecord::Migration[6.1]
  def change
    add_reference :partners, :affiliate, null: true, foreign_key: true
  end
end
