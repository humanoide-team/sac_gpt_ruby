require 'openai'
class Api::V1::Partners::PartnerClientsController < ApiPartnerController
  before_action :set_client, only: %i[lead_classification messages_resume destroy]

  def index
    @clients = @current_partner.partner_clients.order(id: :asc).uniq
    render json: PartnerClientSerializer.new(@clients).serialized_json, status: :ok
  end

  def destroy
    if @client.destroy
      render json: PartnerClientSerializer.new(@client).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@client.errors), status: :unprocessable_entity
    end
  end

  def lead_classification
    historico_conversa = messages(@current_partner, @client)
    pergunta = 'Estime com uma nota de 1 a 5 o quanto o usuario esta interresado em contratar nossos servicos'
    response = gerar_resposta(pergunta, historico_conversa).gsub("\n", ' ').strip
    render json: {
      data: { body: response }
    }, status: :ok
  end

  def messages_resume
    pergunta = 'Faca um resumo de toda essa conversa em um paragrafo'
    historico_conversa = messages(@current_partner, @client)
    response = gerar_resposta(pergunta, historico_conversa).gsub("\n", ' ').strip
    render json: {
      data: { body: response }
    }, status: :ok
  end

  private

  def messages(partner, client)
    historico_conversa = [{ role: 'system', content: partner.partner_detail.message_content }]
    client.partner_client_messages.by_partner(partner).each do |pcm|
      historico_conversa << { role: 'user', content: pcm.message }
      historico_conversa << { role: 'assistant', content: pcm.automatic_response } if pcm.automatic_response
    end
    historico_conversa
  end

  def gerar_resposta(pergunta, historico_conversa)
    return 'Desculpe, não entendi a sua pergunta.' unless pergunta.is_a?(String) && !pergunta.empty?

    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    messages = historico_conversa + [{ role: 'user', content: pergunta }]
    response = client.chat(
      parameters: {
        model: 'gpt-4',
        messages:,
        max_tokens: 1500,
        n: 1,
        stop: nil,
        temperature: 0.7
      }
    )

    response['choices'][0]['message']['content'].strip
  end

  def set_client
    @client = @current_partner.partner_clients.find(params[:id])
  end
end
