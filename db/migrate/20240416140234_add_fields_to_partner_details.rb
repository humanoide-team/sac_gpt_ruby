class AddFieldsToPartnerDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :partner_details, :twitter_x_link, :string
    add_column :partner_details, :youtube_link, :string
    add_column :partner_details, :facebook_link, :string
    add_column :partner_details, :instagram_link, :string
  end
end
