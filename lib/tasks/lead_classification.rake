namespace :lead_classification do
  desc 'Import Transactions'
  task partener_client_classification: :environment do
    partners = Partner.all

    partners.each do |current_partner|
      partner_clients = current_partner.partner_clients.uniq

      partner_clients.each do |client|
        @partner_client_lead = client.partner_client_leads.by_partner(current_partner).first

        last_message = client.partner_client_messages.by_partner(current_partner).last

        historico_conversa = messages(current_partner, client)

        if @partner_client_lead.nil? && last_message.created_at < DateTime.now - 1.hour

          lead_classification_question = 'Com base na interação, classifique o interesse do lead em uma escala de 1 a 5, sendo 1 o menor interesse e 5 o maior interesse. Considere fatores como engajamento, perguntas feitas e intenção de compra e fale por que da nota.'

          lead_classification = gerar_resposta(lead_classification_question, historico_conversa).gsub("\n", ' ').strip

          conversation_summary_question = 'Faca um resumo de toda essa conversa em um paragrafo'
          conversation_summary = gerar_resposta(conversation_summary_question, historico_conversa).gsub("\n", ' ').strip

          lead_score_question = "#{lead_classification}, Qual foi a nota dada ao lead. Responda com apenas o digito e nada mais"
          lead_score = gerar_resposta(lead_score_question, historico_conversa).gsub("\n", ' ').strip

          client.partner_client_leads.create(partner: current_partner,
                                             lead_classification:, conversation_summary:, lead_score: lead_score.to_i)
        elsif !@partner_client_lead.nil? && !last_message.nil? && last_message.created_at > @partner_client_lead.updated_at && last_message.created_at < DateTime.now - 1.hour

          lead_classification_question = 'Com base na interação, classifique o interesse do lead em uma escala de 1 a 5, sendo 1 o menor interesse e 5 o maior interesse. Considere fatores como engajamento, perguntas feitas e intenção de compra e fale por que da nota.'
          lead_classification = gerar_resposta(lead_classification_question, historico_conversa).gsub("\n", ' ').strip

          conversation_summary_question = 'Faca um resumo de toda essa conversa em um paragrafo'
          conversation_summary = gerar_resposta(conversation_summary_question, historico_conversa).gsub("\n", ' ').strip

          lead_score_question = "#{lead_classification}, Qual foi a nota dada ao lead. Responda com apenas o digito e nada mais"
          lead_score = gerar_resposta(lead_score_question, historico_conversa).gsub("\n", ' ').strip

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
      historico_conversa << { role: 'system', content: "Resumo da conversa anterior: #{@partner_client_lead.conversation_summary}"}

      client.partner_client_messages.by_partner(partner).where('created_at > ?', @partner_client_lead.updated_at).order(:created_at).each do |pcm|
        historico_conversa << { role: 'user', content: pcm.message }
        historico_conversa << { role: 'assistant', content: pcm.automatic_response } if pcm.automatic_response
      end
    end

    historico_conversa
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
          max_tokens: 500,
          n: 1,
          stop: nil,
          temperature: 0.7
        }
      )

      token_count = @partner_client_lead.token_count.nil? ? response['usage']['total_tokens'].to_i : @partner_client_lead.token_count += response['usage']['total_tokens'].to_i
      @partner_client_lead.update(token_count:)

      response['choices'][0]['message']['content'].strip
    rescue StandardError => e
      puts e
      puts response
    end
  end
end
