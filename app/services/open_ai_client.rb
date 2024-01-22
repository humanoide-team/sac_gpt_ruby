require 'openai'

class OpenAiClient
  OPEN_AI_KEY = ENV['OPENAI_API_KEY'].freeze

  def self.text_generation(pergunta, historico_conversa, model)
    begin
      client = OpenAI::Client.new(access_token: OPEN_AI_KEY)
      messages = historico_conversa + [{ role: 'user', content: pergunta }]
      response = client.chat(
        parameters: {
          model: model,
          messages:,
          max_tokens: 500,
          n: 1,
          stop: nil,
          temperature: 0.7
        }
      )

      response
    rescue StandardError => e
      puts e
      puts response
      'Falha em gerar resposta'
    end
  end
end
