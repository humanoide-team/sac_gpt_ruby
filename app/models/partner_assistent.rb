class PartnerAssistent < ApplicationRecord
  belongs_to :partner
  has_one :prompt_file

  before_create :create_open_ai_assistent
  after_create :update_assitent_file

  def create_open_ai_assistent
    name_attendant = partner.partner_detail.name_attendant
    company_name = partner.partner_detail.company_name
    company_niche = partner.partner_detail.company_niche
    instructions = "Você é #{name_attendant}, atendente da #{company_name} especializado em #{company_niche}"

    response = OpenAiClient.create_assistent(instructions, name)
    self.open_ai_assistent_id = response['id']
  end

  def update_assitent_file
    delete_assitent_file unless prompt_file.nil?

    file = partner.partner_detail.create_prompt_file(self)
    OpenAiClient.create_assistent_file(open_ai_assistent_id, file.open_ai_file_id)
  end

  def delete_assitent_file
    OpenAiClient.delete_assistent_file(prompt_file.open_ai_file_id)
    prompt_file.destroy!
  end
end
