class Api::V1::Partners::PartnerClientsController < ApiPartnerController
  before_action :set_client, only: %i[lead_classification messages_resume destroy]

  def index
    @clients = @current_partner.partner_clients.sort_by do |pc|
      pc.partner_client_messages.by_partner(@current_partner).last
    end.reverse!.uniq
    render json: {
      data: @clients.map do |pc|
        partner_client_lead = pc.partner_client_leads.by_partner(@current_partner).first
        {
          id: pc.id,
          type: 'partnerClient',
          attributes: {
            name: pc.name,
            phone: pc.phone,
            lastMessage: pc.partner_client_messages.by_partner(@current_partner).last.created_at,
            leadScore: !partner_client_lead.nil? ? partner_client_lead.lead_score : nil,
            createdAt: pc.created_at,
            updatedAt: pc.updated_at
          }
        }
      end
    }, status: :ok
  end

  def destroy
    if @client.destroy
      render json: PartnerClientSerializer.new(@client).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@client.errors), status: :unprocessable_entity
    end
  end

  def lead_classification
    @partner_client_lead = @client.partner_client_leads.by_partner(@current_partner).first

    unless @current_partner.active == true
      if @partner_client_lead.nil?
        @partner_client_lead = LeadClassification.new(partner: @current_partner,
                                                      lead_classification: nil, conversation_summary: nil, lead_score: nil)
      end
      return render json: PartnerClientLeadSerializer.new(@partner_client_lead).serialized_json, status: :ok
    end

    last_message = @client.partner_client_messages.by_partner(@current_partner).last

    historico_conversa = messages(@current_partner, @client)

    if @partner_client_lead.nil?

      @partner_client_lead = @client.partner_client_leads.new(partner: @current_partner, token_count: 0)

      historico_conversa = messages(@current_partner, @client)

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

    elsif !@partner_client_lead.nil? && !last_message.nil? && last_message.created_at + 10.minutes > @partner_client_lead.updated_at

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

      @partner_client_lead.update(lead_classification:, conversation_summary:, lead_score: lead_score.to_i)
    end

    render json: PartnerClientLeadSerializer.new(@partner_client_lead).serialized_json, status: :ok
  end

  def messages_resume
    pergunta = 'Faca um resumo de toda essa conversa em um paragrafo'
    historico_conversa = messages(@current_partner, @client)
    response = gerar_resposta(pergunta, historico_conversa, 'gpt-3.5-turbo').gsub("\n", ' ').strip
    render json: {
      data: { body: response }
    }, status: :ok
  end

  private

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
        montly_history = @current_partner.current_mothly_history
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

  def set_client
    @client = @current_partner.partner_clients.find(params[:id])
  end
end
