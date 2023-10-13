require 'openai'
class Api::V1::WebhooksController < ApiController
  def whatsapp
    @partner = Partner.find_by(instance_key: params['instanceKey'])

    permitted_params = params.permit!
    puts permitted_params
    NodeApiClient.send_callback(permitted_params.to_h)
    puts '***************ENVIOU CALLBACK************************'
    return render json: { status: 'OK', current_date: DateTime.now.to_s, params: } if @partner.nil? || @partner.partner_detail.nil?

    puts '********************RESPONDENDO****************************'

    @client = PartnerClient.find_by(phone: params['body']['key']['remoteJid'])
    if @client.nil?
      @client = PartnerClient.create(phone: params['body']['key']['remoteJid'],
                                     name: params['body']['pushName'])
    end
    @client.update(name: params['body']['pushName']) if params['body']['pushName'] && @client.name.nil?
    pergunta_usuario = if params['body'] && params['body']['message']
                         message = params['body']['message']
                         if message['conversation']
                           conversation = message['conversation']
                           conversation
                         elsif message['extendedTextMessage']
                           text = message['extendedTextMessage']['text']
                           text
                         else
                           ' '
                         end
                       else
                         ' '
                       end

    if @client.partner_client_messages.by_partner(@partner).map(&:webhook_uuid).include?(params['body']['key']['id'])
      render json: { status: 'OK', current_date: DateTime.now.to_s,
                     params: }
    end

    partner_client_message = @client.partner_client_messages.create(partner: @partner, message: pergunta_usuario,
                                                                    webhook_uuid: params['body']['key']['id'])
    Thread.new { aguardar_e_enviar_resposta(@partner, @client, partner_client_message) }
  end

  def aguardar_e_enviar_resposta(partner, client, partner_client_message, tempo_espera = 20)
    sleep(tempo_espera)
    last_response = client.partner_client_messages.by_partner(partner).order(:created_at).last
    return if !last_response.nil? && last_response.created_at > partner_client_message.created_at

    partner_client_conversation_info = client.partner_client_conversation_infos.by_partner(partner).first

    if partner_client_conversation_info.nil?

      historico_conversa = [{ role: 'system', content: @partner.partner_detail.message_content }]

      messages = client.partner_client_messages.by_partner(partner)

      generate_message_history(messages, historico_conversa)

      messages_length = 0

      historico_conversa.each { |m| messages_length += m[:content].length }

      if messages_length >= 4000
        generate_system_conversation_resume(historico_conversa, partner_client_conversation_info, client, partner)
        partner_client_conversation_info = client.partner_client_conversation_infos.by_partner(partner).first

        historico_conversa = [{ role: 'system', content: @partner.partner_detail.message_content }]
        historico_conversa << { role: 'system', content: "Resumo da conversa anterior: #{partner_client_conversation_info.system_conversation_resume}"}
      end

    elsif !partner_client_conversation_info.nil?

      historico_conversa = [{ role: 'system', content: @partner.partner_detail.message_content }]
      historico_conversa << { role: 'system', content: "Resumo da conversa anterior: #{partner_client_conversation_info.system_conversation_resume}"}

      messages = client.partner_client_messages.by_partner(partner).where('created_at > ?', partner_client_conversation_info.updated_at).order(:created_at)

      generate_message_history(messages, historico_conversa)

      messages_length = 0

      historico_conversa.each { |m| messages_length += m[:content].length }

      if messages_length >= 4000
        generate_system_conversation_resume(historico_conversa, partner_client_conversation_info, client, partner)

        historico_conversa = [{ role: 'system', content: @partner.partner_detail.message_content }]
        historico_conversa << { role: 'system', content: "Resumo da conversa anterior: #{partner_client_conversation_info.system_conversation_resume}"}
      end
    end

    response = gerar_resposta(last_response.message, historico_conversa).gsub("\n", ' ').strip
    last_response.update(automatic_response: response)
    response = NodeApiClient.enviar_mensagem(params['body']['key']['remoteJid'], response, partner.instance_key)
    return 'Erro na API Node.js: #{response}' unless response['status'] == 'OK'
  end

  def gerar_resposta(pergunta, historico_conversa)
    return 'Desculpe, não entendi a sua pergunta.' unless pergunta.is_a?(String) && !pergunta.empty?

    begin
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
    rescue StandardError => e
      puts e
      puts response
    end
  end

  def generate_system_conversation_resume(historico_conversa, partner_client_conversation_info, client, partner)
    resume = gerar_resposta('Faca um resumo de toda essa conversa em um paragrafo', historico_conversa).gsub("\n", ' ').strip
    if partner_client_conversation_info.nil?
      client.partner_client_conversation_infos.create(system_conversation_resume: resume, partner:)
    else
      partner_client_conversation_info.update(system_conversation_resume: resume)
    end
  end

  def generate_message_history(messages, historico_conversa)
    messages.each do |pcm|
      historico_conversa << { role: 'user', content: pcm.message }
      historico_conversa << { role: 'assistant', content: pcm.automatic_response } if pcm.automatic_response
    end
  end
end
