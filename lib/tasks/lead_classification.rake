namespace :lead_classification do
  desc 'Import Transactions'
  task partener_client_classification: :environment do
    partners = Partner.all

    partners.each do |current_partner|
      next unless current_partner.active

      @partner = current_partner

      partner_clients = current_partner.partner_clients.uniq

      partner_clients.each do |client|
        @partner_client_lead = client.partner_client_leads.by_partner(current_partner).first

        last_message = client.partner_client_messages.by_partner(current_partner).last

        historico_conversa = messages(current_partner, client)

        if @partner_client_lead.nil? && last_message.created_at < DateTime.now - 1.hour
          @partner_client_lead = client.partner_client_leads.new(partner: current_partner, token_count: 0)

          lead_classification_question = 'Com base na interação, classifique o interesse do lead em uma escala de 1 a 5, sendo 1 o menor interesse e 5 o maior interesse. Considere fatores como engajamento, perguntas feitas e intenção de compra e fale por que da nota.'

          lead_classification = gerar_resposta(lead_classification_question, historico_conversa, 'gpt-3.5-turbo').gsub(
            "\n", ' '
          ).strip

          conversation_summary_question = 'Faca um resumo de toda essa conversa em um paragrafo'
          conversation_summary = gerar_resposta(conversation_summary_question, historico_conversa, 'gpt-3.5-turbo').gsub(
            "\n", ' '
          ).strip

          lead_score_question = "#{lead_classification}, Qual foi a nota dada ao lead. Responda com apenas o digito e nada mais"
          lead_score = gerar_resposta(lead_score_question, historico_conversa, 'gpt-3.5-turbo').gsub("\n", ' ').strip

          @partner_client_lead.lead_classification = lead_classification
          @partner_client_lead.conversation_summary = conversation_summary
          @partner_client_lead.lead_score = lead_score.to_i
          @partner_client_lead.save

        elsif !@partner_client_lead.nil? && !last_message.nil? && last_message.created_at + 10.minutes > @partner_client_lead.updated_at && last_message.created_at < DateTime.now - 1.hour

          lead_classification_question = 'Com base na interação, classifique o interesse do lead em uma escala de 1 a 5, sendo 1 o menor interesse e 5 o maior interesse. Considere fatores como engajamento, perguntas feitas e intenção de compra e fale por que da nota.'
          lead_classification = gerar_resposta(lead_classification_question, historico_conversa).gsub("\n", ' ').strip

          conversation_summary_question = 'Faca um resumo de toda essa conversa em um paragrafo'
          conversation_summary = gerar_resposta(conversation_summary_question, historico_conversa, 'gpt-3.5-turbo').gsub(
            "\n", ' '
          ).strip

          lead_score_question = "#{lead_classification}, Qual foi a nota dada ao lead. Responda com apenas o digito e nada mais"
          lead_score = gerar_resposta(lead_score_question, historico_conversa, 'gpt-3.5-turbo').gsub("\n", ' ').strip

          @partner_client_lead.update(lead_classification:, conversation_summary:, lead_score: lead_score.to_i)
        end
        sleep(5)
      end
    end
  end

  def messages(partner, client)
    historico_conversa = [{ role: 'system', content: partner.partner_detail.message_content }]

    client.partner_client_messages.by_partner(partner).order(:created_at).each do |pcm|
      historico_conversa << { role: 'user', content: pcm.message }
      historico_conversa << { role: 'assistant', content: pcm.automatic_response } if pcm.automatic_response
    end

    messages_length = 0

    if messages_length >= 9500
      historico_conversa = [{ role: 'system', content: partner.partner_detail.message_content }]
      historico_conversa << { role: 'system',
                              content: "Resumo da conversa anterior: #{@partner_client_lead.conversation_summary}" }

      client.partner_client_messages.by_partner(partner).where('created_at > ?',
                                                               @partner_client_lead.updated_at).order(:created_at).each do |pcm|
        historico_conversa << { role: 'user', content: pcm.message }
        historico_conversa << { role: 'assistant', content: pcm.automatic_response } if pcm.automatic_response
      end
    end

    historico_conversa
  end

  def gerar_resposta(pergunta, historico_conversa, model = 'gpt-3.5-turbo')
    return 'Desculpe, não entendi a sua pergunta.' unless pergunta.is_a?(String) && !pergunta.empty?

    begin
      response = OpenAiClient.text_generation(pergunta, historico_conversa, model)
      if response != 'Falha em gerar resposta'
        token_cost = calculate_token(response['usage'], model).round
        montly_history = @partner.current_mothly_history
        montly_history.increase_token_count(token_cost)
        @partner_client_lead.increase_token_count(token_cost)

        response['choices'][0]['message']['content'].strip
      else
        ''
      end
    rescue StandardError => e
      puts e
      puts response
    end
  end

  def calculate_token(usage, model)
    input = usage['prompt_tokens']
    output = usage['completion_tokens']
    create_token_usage(usage, model)
    case model
    when 'gpt-3.5-turbo'
      tokens_input = input * 0.01667
      tokens_output  = output * 0.050
      tokens_input + tokens_output
    when 'gpt-4-turbo-preview'
      tokens_input = input * 0.333
      tokens_output  = output * 0.666
      tokens_input + tokens_output
    else
      input + output
    end
  end

  def create_token_usage(usage, model)
    input = usage['prompt_tokens']
    output = usage['completion_tokens']
    total = usage['total_tokens']

    TokenUsage.create(partner_client: @client, model:, prompt_tokens: input, completion_tokens: output, total_tokens: total)
  end

end
