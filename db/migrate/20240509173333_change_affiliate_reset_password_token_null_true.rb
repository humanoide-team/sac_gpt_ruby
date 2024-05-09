class ChangeAffiliateResetPasswordTokenNullTrue < ActiveRecord::Migration[6.1]
  def change
    change_column_null :affiliates, :reset_password_token, true
  end
end
