class AddNewFieldsToPartnerDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :partner_details, :main_goals, :string
    add_column :partner_details, :business_goals, :string
    add_column :partner_details, :marketing_channels, :string
    add_column :partner_details, :key_differentials, :string
    add_column :partner_details, :target_audience, :string
    add_column :partner_details, :tone_voice, :string
    add_column :partner_details, :week_days, :string
    add_column :partner_details, :meeting_hours, :string
  end
end
