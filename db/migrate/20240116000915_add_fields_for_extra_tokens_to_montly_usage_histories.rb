class AddFieldsForExtraTokensToMontlyUsageHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :montly_usage_histories, :extra_token_half_exceed, :boolean, default: false
    add_column :montly_usage_histories, :extra_token_almost_exceed, :boolean, default: false
    add_column :montly_usage_histories, :exceed_extra_token_mail, :boolean, default: false
  end
end
