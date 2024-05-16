class ChangeProspectCardStatusToString < ActiveRecord::Migration[6.1]
  def change

    change_column :propect_cards, :status, :string

  end
end
