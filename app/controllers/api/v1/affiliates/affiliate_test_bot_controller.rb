class Api::V1::Affiliates::AffiliateTestBotController < ApiAffiliateController
  before_action :set_message, only: %i[read_message]

  def create_bot_message
    @message = @current_affiliate.affiliate_test_bot_messages.create(affiliate_test_bot_message_params)

    if @message
      render json: AffiliateTestBotMessageSerializer.new(@message).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@message.errors), status: :unprocessable_entity
    end
  end

  def test_bot_messages
    @messages = @current_affiliate.affiliate_test_bot_messages.order(:created_at)
    render json: AffiliateTestBotMessageSerializer.new(@messages).serialized_json, status: :ok
  end

  def last_test_bot_message
    @message = @current_affiliate.affiliate_test_bot_messages.order(:created_at).last
    return render json: { error: 'No Messsage found' }, status: :not_found if @message.nil?

    render json: AffiliateTestBotMessageSerializer.new(@message).serialized_json, status: :ok
  end

  def read_message
    return render json: { error: 'No Messsage found' }, status: :not_found if @message.nil?

    if @message.update(read: true)
      render json: AffiliateTestBotMessageSerializer.new(@message).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@message.errors), status: :unprocessable_entity
    end
  end

  def destroy_all_messages
    @messages = @current_affiliate.affiliate_test_bot_messages

    if @messages.destroy_all
      @current_affiliate.affiliate_test_bot_lead.update(lead_classification: nil, conversation_summary: nil, lead_score: 0, token_count: 0)

      render json: { message: 'Test Bot Messages deleted' }, status: :ok
    else
      render json: { error: 'Error deleting Test Bot Messages' }, status: :unprocessable_entity
    end
  end

  def test_bot_lead
    @affiliate_test_bot_lead = @current_affiliate.affiliate_test_bot_lead

    unless @current_affiliate.active == true
      if @affiliate_test_bot_lead.nil?
        @affiliate_test_bot_lead = AffiliateTestBotLead.new(affiliate: @current_affiliate,
                                                        lead_classification: nil, conversation_summary: nil, lead_score: nil)
      end
      return render json: AffiliateTestBotLeadSerializer.new(@affiliate_test_bot_lead).serialized_json, status: :ok
    end

    messages = @current_affiliate.affiliate_test_bot_messages.order(:created_at)

    last_message = @current_affiliate.affiliate_test_bot_messages.order(:created_at).last

    historico_conversa = generate_message_history(@current_affiliate, messages)

    if !@affiliate_test_bot_lead.nil? && !last_message.nil? && last_message.created_at + 10.minutes > @affiliate_test_bot_lead.updated_at

      lead_classification_question = 'Com base na interação, classifique o interesse do lead em uma escala de 1 a 5, sendo 1 o menor interesse e 5 o maior interesse. Considere fatores como engajamento, perguntas feitas e intenção de compra e fale por que da nota.'
      lead_classification = gerar_resposta(lead_classification_question, historico_conversa).gsub(
        "\n", ' '
      ).strip

      conversation_summary_question = 'Faca um resumo de toda essa conversa em um paragrafo em terceira pessoa do singular'
      conversation_summary = gerar_resposta(conversation_summary_question, historico_conversa).gsub(
        "\n", ' '
      ).strip

      lead_score_question = "#{lead_classification}, Qual foi a nota dada ao lead. Responda com apenas o digito e nada mais"
      lead_score = gerar_resposta(lead_score_question, historico_conversa).gsub("\n", ' ').strip

      @affiliate_test_bot_lead.update(lead_classification:, conversation_summary:, lead_score: lead_score.to_i)
    end

    render json: AffiliateTestBotLeadSerializer.new(@affiliate_test_bot_lead).serialized_json, status: :ok
  end

  private

  def generate_message_history(affiliate, messages)
    historico_conversa = [{ role: 'system', content: affiliate.bot_configuration.message_content }]

    messages.each do |pcm|
      historico_conversa << { role: 'user', content: pcm.message }
      historico_conversa << { role: 'assistant', content: pcm.automatic_response } if pcm.automatic_response
    end

    historico_conversa
  end

  def gerar_resposta(pergunta, historico_conversa)
    return 'Desculpe, não entendi a sua pergunta.' unless pergunta.is_a?(String) && !pergunta.empty?

    begin
      response = OpenAiClient.text_generation(pergunta, historico_conversa, ENV['OPENAI_MODEL_LEAD'])
      if response != 'Falha em gerar resposta'
        token_cost = calculate_token(response['usage']).round
        @current_affiliate.calculate_usage(token_cost)
        @affiliate_test_bot_lead.increase_token_count(token_cost)
        response['choices'][0]['message']['content'].strip
      else
        'Desculpe, não entendi a sua pergunta.'
      end
    rescue StandardError => e
      puts e
      puts response
      'Desculpe, não entendi a sua pergunta.'
    end
  end

  def calculate_token(usage)
    input = usage['prompt_tokens']
    output = usage['completion_tokens']
    input + output
  end

  def affiliate_test_bot_message_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:affiliate_test_bot_message])
  end

  def set_message
    @message = @current_affiliate.affiliate_test_bot_messages.find(params[:id])
  end
end
