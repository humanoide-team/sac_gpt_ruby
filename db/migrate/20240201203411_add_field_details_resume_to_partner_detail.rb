class AddFieldDetailsResumeToPartnerDetail < ActiveRecord::Migration[6.1]
  def change
    add_column :partner_details, :details_resume, :string
    add_column :partner_details, :details_resume_date, :datetime
  end
end
