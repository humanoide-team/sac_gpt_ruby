class AddFieldsToMontlyUsageHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :montly_usage_histories, :exceed_mail, :boolean, default: false
    add_column :montly_usage_histories, :almost_exceed, :boolean, default: false
    add_column :montly_usage_histories, :half_exceed, :boolean, default: false
  end
end
