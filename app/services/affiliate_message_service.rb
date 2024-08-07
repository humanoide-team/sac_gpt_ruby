require 'tiktoken_ruby'

class AffiliateMessageService
  def self.process_message(params, affiliate)
    @affiliate = affiliate
    @params = params
    return 'Callback Processado' if @affiliate.bot_configuration.nil? || !@affiliate.active

    return 'Callback Processado' if params['type'] == 'connection'

    @client = AffiliateClient.find_by(phone: params['body']['key']['remoteJid'], affiliate_id: @affiliate.id)
    if @client.nil?
      @client = AffiliateClient.create(phone: params['body']['key']['remoteJid'],
                                       name: params['body']['pushName'], affiliate_id: @affiliate.id)
    end

    return 'Callback Processado' if @client.blocked

    @client.update(name: params['body']['pushName']) if params['body']['pushName'] && @client.name.nil?

    pergunta_usuario = callback_text_message(params)

    return 'Callback Processado' if pergunta_usuario.empty?

    @partner_client_lead = @client.affiliate_client_leads.by_affiliate(@affiliate).first

    if @affiliate_client_lead.nil?
      @affiliate_client_lead = @client.affiliate_client_leads.create(affiliate: @affiliate, token_count: 0)
    end

    if @client.affiliate_client_messages.by_affiliate(@affiliate).map(&:webhook_uuid).include?(params['body']['key']['id'])
      return 'Callback Processado'
    end

    affiliate_client_message = @client.affiliate_client_messages.create(affiliate: @affiliate, message: pergunta_usuario,
                                                                        webhook_uuid: params['body']['key']['id'])
    Thread.new { aguardar_e_enviar_resposta(@affiliate, @client, affiliate_client_message) }
  end

  def self.aguardar_e_enviar_resposta(affiliate, client, affiliate_client_message, tempo_espera = 8)
    sleep(tempo_espera)
    lasts_messages = client.affiliate_client_messages.by_affiliate(affiliate).where(automatic_response: nil,
                                                                                    created_at: (DateTime.now - 1.minute)...DateTime.now).count

    if lasts_messages >= 10
      client.update(blocked: true)
      return 'Callback Processado'
    end
    last_response = client.affiliate_client_messages.by_affiliate(affiliate).order(:created_at).last

    return if !last_response.nil? && last_response.created_at > affiliate_client_message.created_at

    affiliate_client_conversation_info = client.affiliate_client_conversation_infos.by_affiliate(affiliate).first

    bot_configuration_prompt = @affiliate.bot_configuration.message_content

    historico_conversa = [{ role: 'system', content: bot_configuration_prompt }]

    if affiliate_client_conversation_info.nil?

      messages = client.affiliate_client_messages.by_affiliate(affiliate)

      generate_message_history(messages, historico_conversa)

      if num_tokens_from_messages(historico_conversa) >= 1500
        generate_system_conversation_resume(historico_conversa, affiliate_client_conversation_info, client, affiliate)
        affiliate_client_conversation_info = client.affiliate_client_conversation_infos.by_affiliate(affiliate).first

        historico_conversa = [{ role: 'system', content: bot_configuration_prompt }]

        historico_conversa << { role: 'system',
                                content: "Resumo da conversa anterior: #{affiliate_client_conversation_info.system_conversation_resume}" }
      end

    else
      historico_conversa << { role: 'system',
                              content: "Resumo da conversa anterior: #{affiliate_client_conversation_info.system_conversation_resume}" }

      messages = client.affiliate_client_messages.by_affiliate(affiliate).where('created_at > ?',
                                                                                affiliate_client_conversation_info.updated_at).order(:created_at)

      generate_message_history(messages, historico_conversa)

      if num_tokens_from_messages(historico_conversa) >= 1500
        generate_system_conversation_resume(historico_conversa, affiliate_client_conversation_info, client, affiliate)

        historico_conversa = [{ role: 'system', content: bot_configuration_prompt }]

        historico_conversa << { role: 'system',
                                content: "Resumo da conversa anterior: #{affiliate_client_conversation_info.system_conversation_resume}" }
      end
    end

    text_response = gerar_resposta(last_response.message, historico_conversa).gsub("\n",
                                                                                   ' ').strip
    last_response.update(automatic_response: text_response)
    response = NodeApiClient.enviar_mensagem(@params['body']['key']['remoteJid'], text_response, affiliate.instance_key)
    return "Erro na API Node.js: #{response}" unless response['status'] == 'OK'

    'Callback Processado'
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
        @affiliate.calculate_usage(token_cost)
        @affiliate_client_lead.increase_token_count(token_cost)
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

  def self.generate_prompt_resume(bot_configuration_prompt)
    if @affiliate.bot_configuration.details_resume.nil? || @affiliate.bot_configuration.details_resume_date > @affiliate.bot_configuration.updated_at
      bot_configuration_prompt = [{ role: 'system', content: bot_configuration_prompt }]

      resume = gerar_resposta('Faca um resumo das suas instrucoes em no maximo 100 palavras como se vc estivesse instruindo outra pessoa.', bot_configuration_prompt).gsub("\n",
                                                                                                                                                                           ' ').strip
      @affiliate.bot_configuration.update(details_resume: resume, details_resume_date: DateTime.now)
    end
    @affiliate.bot_configuration.details_resume
  end

  def self.generate_system_conversation_resume(historico_conversa, affiliate_client_conversation_info, client, affiliate)
    resume = gerar_resposta('Faca um resumo de toda essa conversa em um paragrafo', historico_conversa).gsub("\n",
                                                                                                             ' ').strip
    if affiliate_client_conversation_info.nil?
      client.affiliate_client_conversation_infos.create(system_conversation_resume: resume, affiliate:)
    else
      affiliate_client_conversation_info.update(system_conversation_resume: resume)
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
    input + output
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
