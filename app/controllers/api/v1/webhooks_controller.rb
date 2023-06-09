require 'openai'
class Api::V1::WebhooksController < ApiController
  def whatsapp
    @partner = Partner.find_by(instance_key: params['instanceKey'])
    render json: { status: 'OK', current_date: DateTime.now.to_s, params: } if @partner.nil?

    @client = PartnerClient.find_by(phone: params['body']['key']['remoteJid'])
    @client = PartnerClient.create(phone: params['body']['key']['remoteJid'], name: params['body']['pushName']) if @client.nil?
    @client.update(name: params['body']['pushName']) if params['body']['pushName'] && @client.name.nil?

    pergunta_usuario = params['body']['text']['messages'][0]['message']['conversation']
    render json: { status: 'OK', current_date: DateTime.now.to_s, params: } if @client.partner_client_messages.by_partner(@partner).map(&:webhook_uuid).include?(params['body']['key']['id'])

    partner_client_message = @client.partner_client_messages.create(partner: @partner, message: pergunta_usuario, webhook_uuid: params['body']['key']['id'])
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
    response = NodeAPIClient.enviar_mensagem(params['body']['key']['remoteJid'], response)
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
