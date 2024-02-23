class PromptFile < ApplicationRecord
  belongs_to :partner_detail
  belongs_to :partner_assistent

  before_create :create_open_ai_file
  before_destroy :delete_open_ai_file

  def create_open_ai_file
    dados = []
    dados << { instructions: partner_detail.message_content }

    dados << { instructions: partner_detail.observations } unless partner_detail.observations.empty?

    file_path = "./#{partner_assistent.id}_dados.jsonl"
    
    File.write(file_path, dados.to_json)
    new_file = File.new(file_path, 'rb')

    response = OpenAiClient.upload_file(new_file)
    self.open_ai_file_id = response['id']
    File.delete(file_path)
  end

  def delete_open_ai_file
    OpenAiClient.delete_file(open_ai_file_id)
  end
end
