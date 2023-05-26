require 'openai'

class Api::V1::WebhooksController < ApiController
  include HTTParty

  def whatsapp
    @partner = Partner.find_by(phone: params['message']['to'])
    render json: { status: 'OK', current_date: DateTime.now.to_s, params: } if @partner.nil?

    @client = PartnerClient.find_by(phone: params['message']['from'])
    @client = PartnerClient.create(phone: params['message']['from']) if @client.nil?

    pergunta_usuario = params['message']['contents'][0]['text']
    render json: { status: 'OK', current_date: DateTime.now.to_s, params: } if @client.partner_client_messages.by_partner(@partner).map(&:message).include?(pergunta_usuario)

    @client.partner_client_messages.create(partner: @partner, message: pergunta_usuario)
    aguardar_e_enviar_resposta(@partner, @client, pergunta_usuario)
  end

  def aguardar_e_enviar_resposta(partner, client, pergunta_usuario, tempo_espera=15)
    zenvia_sandbox_api_url = 'https://api.zenvia.com/v2/channels/whatsapp/messages'

    sleep(tempo_espera)
    last_response = client.partner_client_messages.by_partner(partner).where.not(automatic_response: nil).order(:created_at).last
    return if !last_response.nil? && (DateTime.now - tempo_espera.seconds) < last_response.created_at

    @client.partner_client_messages.by_partner(partner).last.update(automatic_response: '--')
    historico_conversa = [{ role: 'system', content: @partner.partner_detail.message_content }]
    @client.partner_client_messages.by_partner(partner).each do |partner_client_message|
      historico_conversa << { role: 'user', content: partner_client_message.message }
      historico_conversa << { role: 'assistant', content: partner_client_message.automatic_response } if partner_client_message.automatic_response
    end

    response = gerar_resposta(pergunta_usuario, historico_conversa).gsub("\n", ' ').strip
    @client.partner_client_messages.by_partner(partner).last.update(automatic_response: response)

    headers = {
      'Content-Type': 'application/json',
      'X-API-TOKEN': ENV['ZENVIA_API_KEY']
    }
    data = {
      from: params['message']['to'],
      to: params['message']['from'],
      contents: [{ type: 'text', text: response }]
    }

    response = HTTParty.post(zenvia_sandbox_api_url, body: data.to_json, headers:)
    puts "Erro na API do Zenvia: #{response.body}" if response.code != 200
  end

  def gerar_resposta(pergunta, historico_conversa)
    return 'Desculpe, não entendi a sua pergunta.' unless pergunta.is_a?(String) && !pergunta.empty?

    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    messages = historico_conversa + [{ role: 'user', content: pergunta }]
    response = client.chat(
      parameters: {
        model: 'gpt-4',
        messages: messages,
        max_tokens: 1500,
        n: 1,
        stop: nil,
        temperature: 0.7
      }
    )

    response['choices'][0]['message']['content'].strip
  end
end
