require 'tiktoken_ruby'

class Api::V1::WebhooksAssistentController < ApiController
  def whatsapp
    @partner = Partner.find_by(instance_key: params['instanceKey'])

    permitted_params = params.permit!
    puts permitted_params
    NodeApiClient.send_callback(permitted_params.to_h)
    puts '***************ENVIOU CALLBACK************************'

    if @partner.nil? || @partner.partner_detail.nil? || !@partner.active
      return render json: { status: 'OK', current_date: DateTime.now.to_s,
                            params: }
    end

    puts '********************RESPONDENDO****************************'

    @client = PartnerClient.find_by(phone: params['body']['key']['remoteJid'], partner_id: @partner.id)
    if @client.nil?
      @client = PartnerClient.create(phone: params['body']['key']['remoteJid'],
                                     name: params['body']['pushName'], partner_id: @partner.id)
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

    @partner_client_lead = @client.partner_client_leads.by_partner(@partner).first

    if @partner_client_lead.nil?
      @partner_client_lead = @client.partner_client_leads.create(partner: @partner, token_count: 0)
    end

    if @client.partner_client_messages.by_partner(@partner).map(&:webhook_uuid).include?(params['body']['key']['id'])
      render json: { status: 'OK', current_date: DateTime.now.to_s,
                     params: }
    end

    partner_client_message = @client.partner_client_messages.create(partner: @partner, message: pergunta_usuario,
                                                                    webhook_uuid: params['body']['key']['id'])
    Thread.new { aguardar_e_enviar_resposta(@partner, @client, partner_client_message) }
  end

  def aguardar_e_enviar_resposta(partner, client, partner_client_message, tempo_espera = 8)
    sleep(tempo_espera)
    last_response = client.partner_client_messages.by_partner(partner).order(:created_at).last
    return if !last_response.nil? && last_response.created_at > partner_client_message.created_at

    text_response = gerar_resposta(last_response, 'gpt-4-0125-preview').gsub("\n", ' ').strip

    text_response = identificar_agendamento(text_response)
    last_response.update(automatic_response: text_response)
    response = NodeApiClient.enviar_mensagem(params['body']['key']['remoteJid'], text_response, partner.instance_key)
    return "Erro na API Node.js: #{response}" unless response['status'] == 'OK'
  end

  def gerar_resposta(pcm, _model = 'gpt-3.5-turbo')
    return 'Desculpe, não entendi a sua pergunta.' unless pergunta.is_a?(String) && !pergunta.empty?

    begin
      conversation_thread = if @client.thread_conversation.nil?
                              ConversationThread.create(partner_client: @client, partner: @partner,
                                                        partner_assistent: @partner.partner_assistent)
                            else
                              @client.thread_conversation
                            end

      conversation_thread.create_message(pcm)
      conversation_thread.run_thread
      conversation_thread.retrive_automatic_response.strip
    rescue StandardError => e
      puts e
      puts response
      sleep(40)
      'Desculpe, não entendi a sua pergunta.'
    end
  end

  def identificar_email(response)
    regex = /#E-mail informado: ([\w+\-.]+@[a-z\d\-.]+\.[a-z]+)#/
    match_data = response.match(regex)

    return response unless match_data

    if @client.update(email: match_data[1])
      response
    else
      'Nao foi possivel identificar o seu email'
    end
  end

  def identificar_agendamento(response)
    response = identificar_email(response)

    regex = %r{#Agendamento para o dia (\d{2}/\d{2}/\d{4}) às (\d{2}:\d{2})#}
    match_data = response.match(regex)

    return response unless match_data

    if !@partner.partner_detail.meeting_objective? || @partner.schedule_setting.nil?
      return 'Não foi possível marcar a reunião no momento, nossa equipe entrará em contato direto'
    end

    data_hora_string = "#{match_data[1]} #{match_data[2]}"
    data_hora = DateTime.strptime(data_hora_string, '%d/%m/%Y %H:%M')
    schedule = Schedule.create(summary: 'Agendamento de reuniao!', description: "Agendamento para o dia #{match_data[1]} as #{match_data[2]} com o cliente #{@client.name}", date_time_start: data_hora + 3.hours,
                               date_time_end: data_hora + @partner.schedule_setting.duration_in_minutes.minutes + 3.hours, partner_id: @partner.id, partner_client_id: @client.id)

    if schedule
      response
    else
      'Não foi possível marcar a reunião no momento, nossa equipe entrará em contato direto'
    end
  end
end
