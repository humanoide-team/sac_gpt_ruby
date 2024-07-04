class ClientIdToBeNullableInSchedule < ActiveRecord::Migration[6.1]
  def up
    change_column :schedules, :partner_client_id, :integer, null: true
  end

  def down
    change_column :schedules, :partner_client_id, :integer, null: false
  end
end
