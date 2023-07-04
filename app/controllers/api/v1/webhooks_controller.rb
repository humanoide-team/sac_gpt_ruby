require 'openai'
require_relative '../../../services/node_api_client'

class Api::V1::WebhooksController < ApiController
  include HTTParty

  def auth_whatsapp
    token = 'TOKEN_TOKEN'
    response = NodeAPIClient.iniciar_instancia(token)# criar uma nova instancia da api

    if response['error'] == false
      key = response['key']
      sleep(5)
      get_qrcode(key)
    else
      error_message = response['message']
    end
  end

  def get_qrcode(key)
    qr_code = NodeAPIClient.obter_qr(key)
    render json: qr_code
  end

  def whatsapp
    @partner = Partner.find_by(phone: params['message']['to'])
    render json: { status: 'OK', current_date: DateTime.now.to_s, params: } if @partner.nil?

    @client = PartnerClient.find_by(phone: params['message']['from'])
    @client = PartnerClient.create(phone: params['message']['from'], name: params['message']['visitor']['name']) if @client.nil?
    @client.update(name: params['message']['visitor']['name']) if params['message']['visitor']['name'] && @client.name.nil?

    pergunta_usuario = params['message']['contents'][0]['text']
    render json: { status: 'OK', current_date: DateTime.now.to_s, params: } if @client.partner_client_messages.by_partner(@partner).map(&:webhook_uuid).include?(params['id'])

    partner_client_message = @client.partner_client_messages.create(partner: @partner, message: pergunta_usuario, webhook_uuid: params['id'])
    Thread.new { aguardar_e_enviar_resposta(@partner, @client, partner_client_message) }
  end

  def aguardar_e_enviar_resposta(partner, client, partner_client_message, tempo_espera = 10)
    sleep(tempo_espera)
    last_response = client.partner_client_messages.by_partner(partner).where.not(automatic_response: nil).order(:created_at).last
    return if !last_response.nil? && (DateTime.now - 20.seconds) < last_response.created_at

    historico_conversa = [{ role: 'system', content: @partner.partner_detail.message_content }]
    @client.partner_client_messages.by_partner(partner).each do |pcm|
      historico_conversa << { role: 'user', content: pcm.message }
      historico_conversa << { role: 'assistant', content: pcm.automatic_response } if pcm.automatic_response
    end

    response = gerar_resposta(partner_client_message.message, historico_conversa).gsub("\n", ' ').strip
    partner_client_message.update(automatic_response: response)
    response = NodeAPIClient.enviar_mensagem(params['message']['to'], response)
    return 'Erro na API Node.js: #{response}' unless response['status'] == 'OK'
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
