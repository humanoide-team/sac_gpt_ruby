class ConversationThread < ApplicationRecord
  belongs_to :partner
  belongs_to :partner_client
  belongs_to :partner_assistent
  has_many :partner_client_messages

  before_create :create_open_ai_thread

  def create_open_ai_thread
    response = OpenAiClient.create_thread

    self.open_ai_thread_id = response['id']
  end

  def create_message(pcm)
    message = { role: 'user', content: pcm.message }

    response = OpenAiClient.create_message(self.open_ai_thread_id, message)

    pcm.update(open_ai_message_id: response['id'])
  end

  def run_thread
    response = OpenAiClient.run_thread(partner_assistent.open_ai_assistent_id, self.open_ai_thread_id)
    self.update(open_ai_last_run_id:response['id'])
  end

  def retrive_automatic_response
    response = OpenAiClient.thread_messages(self.open_ai_thread_id)
    response[-1]['content']['text']
  end

end
