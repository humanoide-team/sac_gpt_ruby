class ChangeColumnCompanyObjectives < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      ALTER TABLE partner_details
      ALTER COLUMN tone_voice TYPE character varying[]
      USING CASE
        WHEN tone_voice IS NOT NULL THEN ARRAY[tone_voice]
        ELSE '{}'::character varying[]
      END;
    SQL
    change_column_default :partner_details, :tone_voice, []
  end

  def down
    execute <<-SQL
      ALTER TABLE partner_details
      ALTER COLUMN tone_voice TYPE character varying
      USING tone_voice[1];
    SQL
  end
end
