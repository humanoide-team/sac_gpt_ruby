require 'mistral-ai'

class MistralAiClient
  MISTRAL_API_KEY = ENV['MISTRAL_API_KEY'].freeze

  def self.text_generation(pergunta, historico_conversa, _model)
    messages = historico_conversa + [{ role: 'user', content: pergunta }]

    client = Mistral.new(
      credentials: { api_key: MISTRAL_API_KEY },
      options: { server_sent_events: true }
    )
    response = client.chat_completions({ model: 'mistral-medium', messages: })
  rescue StandardError => e
    puts e
    puts response
    'Falha em gerar resposta'
  end
end
