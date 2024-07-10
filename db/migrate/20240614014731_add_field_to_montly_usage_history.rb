class AddFieldToMontlyUsageHistory < ActiveRecord::Migration[6.1]
  def change
    add_column :montly_usage_histories, :extra_token_count, :integer, default: 0
  end
end
