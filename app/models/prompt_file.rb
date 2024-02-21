class PromptFile < ApplicationRecord
  belongs_to :partner_detail
  belongs_to :partner_assistent

  before_create :create_open_ai_file
  before_destroy :delete_open_ai_file

  def create_open_ai_file(assistent)
    dados = []
    dados << { instructions: partner_detail.message_content }

    dados << { instructions: @partner.partner_detail.observations } unless partner_detail.observations.empty?
    new_file = File.open('dados.jsonl', 'w')

    new_file do |file|
      dados.each do |obj|
        file.puts(obj.to_json)
      end
    end

    response = OpenAiClient.upload_file(new_file)
    self.open_ai_file_id = response['id']
    self.partner_assistent_id = assistent.id
  end

  def delete_open_ai_file
    OpenAiClient.delete_file(open_ai_file_id)
  end
end
