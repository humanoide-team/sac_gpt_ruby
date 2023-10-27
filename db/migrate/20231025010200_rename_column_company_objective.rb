class RenameColumnCompanyObjective < ActiveRecord::Migration[6.1]
  def change
    rename_column :partner_details, :company_objective, :company_objectives
  end
end
