require 'tiktoken_ruby'

class PartnerMessageService
  MODEL = ENV['OPENAI_MODEL'].freeze

  def self.process_message(params, partner)
    @partner = partner
    @params = params
    return if @partner.partner_detail.nil? || !@partner.active

    if params['type'] == 'connection'

      if params['body']['connection'] == 'open' && @partner.wpp_connected == false
        @partner.update(last_callback_receive: DateTime.now, wpp_connected: true)

      elsif params['body']['connection'] == 'close' && @partner.wpp_connected == true
        @partner.update(wpp_connected: false)
        @partner.send_connection_fail_mail
      end
      return
    end

    @partner.update(last_callback_receive: DateTime.now, wpp_connected: true)

    @client = PartnerClient.find_by(phone: params['body']['key']['remoteJid'], partner_id: @partner.id)
    if @client.nil?
      @client = PartnerClient.create(phone: params['body']['key']['remoteJid'],
                                     name: params['body']['pushName'], partner_id: @partner.id)
    end

    return if @client.blocked

    @client.update(name: params['body']['pushName']) if params['body']['pushName'] && @client.name.nil?

    pergunta_usuario = callback_text_message(params)

    return if pergunta_usuario.empty?

    @partner_client_lead = @client.partner_client_leads.by_partner(@partner).first

    if @partner_client_lead.nil?
      @partner_client_lead = @client.partner_client_leads.create(partner: @partner, token_count: 0)
    end

    if @client.partner_client_messages.by_partner(@partner).map(&:webhook_uuid).include?(params['body']['key']['id'])
      return
    end

    partner_client_message = @client.partner_client_messages.create(partner: @partner, message: pergunta_usuario,
                                                                    webhook_uuid: params['body']['key']['id'])
    Thread.new { aguardar_e_enviar_resposta(@partner, @client, partner_client_message) }
  end

  def self.aguardar_e_enviar_resposta(partner, client, partner_client_message, tempo_espera = 8)
    sleep(tempo_espera)
    lasts_messages = client.partner_client_messages.by_partner(partner).where(automatic_response: nil,
                                                                              created_at: (DateTime.now - 1.minute)...DateTime.now).count

    if lasts_messages >= 10
      client.update(blocked: true)
      return
    end

    last_response = client.partner_client_messages.by_partner(partner).order(:created_at).last
    return if !last_response.nil? && last_response.created_at > partner_client_message.created_at

    partner_client_conversation_info = client.partner_client_conversation_infos.by_partner(partner).first

    partner_detail_prompt = @partner.partner_detail.message_content

    # if client.partner_client_messages.by_partner(partner).size > 1
    #   partner_detail_prompt = generate_prompt_resume(partner_detail_prompt)
    # end

    historico_conversa = [{ role: 'system', content: partner_detail_prompt }]

    unless @partner.partner_detail.observations.empty?
      historico_conversa << { role: 'system', content: @partner.partner_detail.observations }
    end

    if partner_client_conversation_info.nil?

      messages = client.partner_client_messages.by_partner(partner)

      generate_message_history(messages, historico_conversa)

      if num_tokens_from_messages(historico_conversa) >= 1500
        generate_system_conversation_resume(historico_conversa, partner_client_conversation_info, client, partner)
        partner_client_conversation_info = client.partner_client_conversation_infos.by_partner(partner).first

        historico_conversa = [{ role: 'system', content: partner_detail_prompt }]

        unless @partner.partner_detail.observations.empty?
          historico_conversa << { role: 'system', content: @partner.partner_detail.observations }
        end

        historico_conversa << { role: 'system',
                                content: "Resumo da conversa anterior: #{partner_client_conversation_info.system_conversation_resume}" }
      end

    else
      historico_conversa << { role: 'system',
                              content: "Resumo da conversa anterior: #{partner_client_conversation_info.system_conversation_resume}" }

      messages = client.partner_client_messages.by_partner(partner).where('created_at > ?',
                                                                          partner_client_conversation_info.updated_at).order(:created_at)

      generate_message_history(messages, historico_conversa)

      if num_tokens_from_messages(historico_conversa) >= 1500
        generate_system_conversation_resume(historico_conversa, partner_client_conversation_info, client, partner)

        historico_conversa = [{ role: 'system', content: partner_detail_prompt }]

        unless @partner.partner_detail.observations.empty?

          historico_conversa << { role: 'system', content: @partner.partner_detail.observations }
        end

        historico_conversa << { role: 'system',
                                content: "Resumo da conversa anterior: #{partner_client_conversation_info.system_conversation_resume}" }
      end
    end

    text_response = gerar_resposta(last_response.message, historico_conversa).gsub("\n",
                                                                                   ' ').strip
    text_response = identificar_agendamento(text_response)
    last_response.update(automatic_response: text_response)
    response = NodeApiClient.enviar_mensagem(@params['body']['key']['remoteJid'], text_response, partner.instance_key)
    return "Erro na API Node.js: #{response}" unless response['status'] == 'OK'
  end

  def self.identificar_email(response)
    regex = /#E-mail informado: ([\w+\-.]+@[a-z\d\-.]+\.[a-z]+)#/
    match_data = response.match(regex)

    return response unless match_data

    if @client.update(email: match_data[1])
      response
    else
      'Nao foi possivel identificar o seu email'
    end
  end

  def self.identificar_agendamento(response)
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
                               date_time_end: data_hora + @partner.schedule_setting.duration_in_minutes.minutes + @partner.schedule_setting.interval_minutes.minutes + 3.hours, partner_id: @partner.id, partner_client_id: @client.id)

    if schedule
      response
    else
      'Não foi possível marcar a reunião no momento, nossa equipe entrará em contato direto'
    end
  end

  def self.gerar_resposta(pergunta, historico_conversa)
    return 'Desculpe, não entendi a sua pergunta.' unless pergunta.is_a?(String) && !pergunta.empty?

    if pergunta == 'MEDIA_MESSAGE'
      return 'Atualmente, a versão do WhatsApp que estou utilizando não consegue processar arquivos de mídia como gifs, áudios ou imagens. Por favor, envie texto para que eu possa ajudar da melhor maneira possível. Se precisar de assistência adicional, estou à disposição para responder suas perguntas. Obrigado!'
    end

    begin
      response = OpenAiClient.text_generation(pergunta, historico_conversa, ENV['OPENAI_MODEL'])
      if response != 'Falha em gerar resposta'
        token_cost = calculate_token(response['usage']).round
        @partner.calculate_usage(token_cost)
        @partner_client_lead.increase_token_count(token_cost)
        response['choices'][0]['message']['content'].strip
      else
        'Desculpe, não entendi a sua pergunta.'
      end
    rescue StandardError => e
      puts e
      puts response
      sleep(40)
      'Desculpe, não entendi a sua pergunta.'
    end
  end

  def self.generate_prompt_resume(partner_detail_prompt)
    if @partner.partner_detail.details_resume.nil? || @partner.partner_detail.details_resume_date > @partner.partner_detail.updated_at
      partner_detail_prompt = [{ role: 'system', content: partner_detail_prompt }]

      resume = gerar_resposta('Faca um resumo das suas instrucoes em no maximo 100 palavras como se vc estivesse instruindo outra pessoa.', partner_detail_prompt).gsub("\n",
                                                                                                                                                                        ' ').strip
      @partner.partner_detail.update(details_resume: resume, details_resume_date: DateTime.now)
    end
    @partner.partner_detail.details_resume
  end

  def self.generate_system_conversation_resume(historico_conversa, partner_client_conversation_info, client, partner)
    resume = gerar_resposta('Faca um resumo de toda essa conversa em um paragrafo', historico_conversa).gsub("\n",
                                                                                                             ' ').strip
    if partner_client_conversation_info.nil?
      client.partner_client_conversation_infos.create(system_conversation_resume: resume, partner:)
    else
      partner_client_conversation_info.update(system_conversation_resume: resume)
    end
  end

  def self.generate_message_history(messages, historico_conversa)
    messages.each do |pcm|
      historico_conversa << { role: 'user', content: pcm.message }
      historico_conversa << { role: 'assistant', content: pcm.automatic_response } if pcm.automatic_response
    end
  end

  def self.calculate_token(usage)
    input = usage['prompt_tokens']
    output = usage['completion_tokens']
    create_token_usage(usage)
    input + output
  end

  def self.create_token_usage(usage)
    input = usage['prompt_tokens']
    output = usage['completion_tokens']
    total = usage['total_tokens']

    TokenUsage.create(partner_client: @client, model: ENV['OPENAI_MODEL'], prompt_tokens: input, completion_tokens: output,
                      total_tokens: total)
  end

  def self.num_tokens_from_messages(messages)
    encoding = Tiktoken.encoding_for_model(ENV['OPENAI_MODEL'])
    num_tokens = 0
    messages.each do |message|
      num_tokens += 4
      message.each do |key, value|
        num_tokens += encoding.encode(value).length
        num_tokens -= 1 if key == 'name'
      end
    end
    num_tokens += 2
    num_tokens
  end

  def self.callback_text_message(params)
    if params['body'] && params['body']['message']
      message = params['body']['message']
      if message['conversation']
        message['conversation']
      elsif message['extendedTextMessage']
        message['extendedTextMessage']['text']
      elsif message['imageMessage'] || message['stickerMessage'] || message['reactionMessage'] || message['audioMessage'] || message['documentMessage'] || message['videoMessage']
        'MEDIA_MESSAGE'
      else
        ''
      end
    else
      ''
    end
  end
end
