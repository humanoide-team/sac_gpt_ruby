class Api::V1::Affiliates::AffiliateClientsController < ApiAffiliateController
  before_action :set_client, only: %i[lead_classification messages_resume destroy]

  def index
    @clients = @current_affiliate.affiliate_clients.sort_by do |ac|
      last_message = ac.affiliate_client_messages.by_affiliate(@current_affiliate).last
      last_message ? last_message.created_at : Time.at(0)
    end.reverse.uniq
    render json: {
      data: @clients.map do |ac|
        affiliate_client_lead = ac.affiliate_client_leads.by_affiliate(@current_affiliate).first
        {
          id: ac.id,
          type: 'affiliateClient',
          attributes: {
            name: ac.name,
            phone: ac.phone,
            lastMessage: ac.affiliate_client_messages.by_affiliate(@current_affiliate).last&.created_at,
            leadScore: !affiliate_client_lead.nil? ? affiliate_client_lead.lead_score : nil,
            createdAt: ac.created_at,
            updatedAt: ac.updated_at
          }
        }
      end
    }, status: :ok
  end

  def destroy
    if @client.destroy
      render json: AffiliateClientSerializer.new(@client).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@client.errors), status: :unprocessable_entity
    end
  end

  def lead_classification
    @affiliate_client_lead = @client.affiliate_client_leads.by_affiliate(@current_affiliate).first

    unless @current_affiliate.active == true
      if @affiliate_client_lead.nil?
        @affiliate_client_lead = LeadClassification.new(affiliate: @current_affiliate,
                                                      lead_classification: nil, conversation_summary: nil, lead_score: nil)
      end
      return render json: AffiliateClientLeadSerializer.new(@affiliate_client_lead).serialized_json, status: :ok
    end

    last_message = @client.affiliate_client_messages.by_affiliate(@current_affiliate).last

    historico_conversa = messages(@current_affiliate, @client)

    if @affiliate_client_lead.nil?

      @affiliate_client_lead = @client.affiliate_client_leads.new(affiliate: @current_affiliate, token_count: 0)

      historico_conversa = messages(@current_affiliate, @client)

      lead_classification_question = 'Com base na interação, classifique o interesse do lead em uma escala de 1 a 5, sendo 1 o menor interesse e 5 o maior interesse. Considere fatores como engajamento, perguntas feitas e intenção de compra e fale por que da nota.'
      lead_classification = gerar_resposta(lead_classification_question, historico_conversa, 'gpt-3.5-turbo').gsub(
        "\n", ' '
      ).strip

      @affiliate_client_lead.lead_classification = lead_classification
      @affiliate_client_lead.save
    end

    render json: AffiliateClientLeadSerializer.new(@affiliate_client_lead).serialized_json, status: :ok
  end

  def messages_resume
    pergunta = 'Faca um resumo de toda essa conversa em um paragrafo'
    historico_conversa = messages(@current_affiliate, @client)
    response = gerar_resposta(pergunta, historico_conversa, 'gpt-3.5-turbo').gsub("\n", ' ').strip
    render json: {
      data: { body: response }
    }, status: :ok

  end

  private

  def messages(affiliate, client)
    historico_conversa = [{ role: 'system', content: affiliate.bot_configuration.message_content }]

    client.affiliate_client_messages.by_affiliate(affiliate).each do |message|
      historico_conversa << { role: 'user', content: message.message }
      historico_conversa << { role: 'system', content: message.automatic_response } if message.automatic_response.present?
    end

    messages_length = 0

    if messages_length >= 9500
      historico_conversa = [{ role: 'system', content: affiliate.bot_configuration.message_content }]
      historico_conversa << { role: 'system', content: "Resumo da conversa anterior: #{@affiliate_client_lead.conversation_summary}" }

      client.affiliate_client_messages.by_affiliate(affiliate).where('created_at > ?', @affiliate_client_lead.updated_at).order(:created_at).each do |message|
        historico_conversa << { role: 'user', content: message.message }
        historico_conversa << { role: 'system', content: message.automatic_response } if message.automatic_response.present?

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
        montly_history = @current_affiliate.current_mothly_history
        montly_history.increase_token_count(token_cost)
        @affiliate_client_lead.increase_token_count(token_cost)

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

    TokenUsage.create(affiliate_client: @client, model:, prompt_tokens: input, completion_tokens: output, total_tokens: total)
  end

  def set_client
    @client = @current_affiliate.affiliate_clients.find(params[:id])
  end
end