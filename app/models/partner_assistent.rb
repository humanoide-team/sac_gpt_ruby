class PartnerAssistent < ApplicationRecord
  belongs_to :partner
  has_many :prompt_files, dependent: :destroy
  has_one :conversation_thread, dependent: :destroy

  before_create :create_open_ai_assistent

  def create_open_ai_assistent
    name_attendant = partner.partner_detail.name_attendant
    prompt_instructions = partner.partner_detail.message_content
    observation_instructions = partner.partner_detail.observations
    instructions = "#{prompt_instructions} #{observation_instructions}"

    response = OpenAiClient.create_assistent(instructions, name_attendant)
    self.open_ai_assistent_id = response['id']
  end

  def update_assistent
    name_attendant = partner.partner_detail.name_attendant
    prompt_instructions = partner.partner_detail.message_content
    observation_instructions = partner.partner_detail.observations
    instructions = "#{prompt_instructions} #{observation_instructions}"

    OpenAiClient.update_assistent(open_ai_assistent_id, instructions, name_attendant)
  end

  def update_assistent_file(open_ai_file_id)
    OpenAiClient.create_assistent_file(open_ai_assistent_id, open_ai_file_id)
  end

  def delete_assistent_file
    OpenAiClient.delete_assistent_file(open_ai_assistent_id, prompt_file.open_ai_file_id)
    prompt_file.destroy!
  end
end
