class PromptFileSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :camel_lower

  attributes :partner_detail_id, :partner_assistent_id, :open_ai_file_id, :file_name, :created_at, :updated_at
end
