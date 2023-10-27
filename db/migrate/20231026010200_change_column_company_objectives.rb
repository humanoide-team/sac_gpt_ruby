class ChangeColumnCompanyObjectives < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      ALTER TABLE partner_details
      ALTER COLUMN company_objectives TYPE character varying[]
      USING CASE
        WHEN company_objectives IS NOT NULL THEN ARRAY[company_objectives]
        ELSE '{}'::character varying[]
      END;
    SQL
    change_column_default :partner_details, :company_objectives, []
  end

  def down
    execute <<-SQL
      ALTER TABLE partner_details
      ALTER COLUMN company_objectives TYPE character varying
      USING company_objectives[1];
    SQL
  end
end