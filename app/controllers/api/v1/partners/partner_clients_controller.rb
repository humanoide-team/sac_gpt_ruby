require 'openai'
class Api::V1::Partners::PartnerClientsController < ApiPartnerController
  before_action :set_client, only: %i[lead_classification messages_resume destroy]

  def index
    @clients = @current_partner.partner_clients.order(id: :asc).uniq

    render json: {
      data: @clients.map do |pc|
        partner_client_lead = pc.partner_client_leads.by_partner(@current_partner).first
        {
          id: pc.id,
          type: 'partnerClient',
          attributes: {
            name: pc.name,
            phone: pc.phone,
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

    last_message = @client.partner_client_messages.by_partner(@current_partner).last

    historico_conversa = messages(@current_partner, @client)

    if @partner_client_lead.nil?

      historico_conversa = messages(@current_partner, @client)

      lead_classification_question = 'Com base na interação, classifique o interesse do lead em uma escala de 1 a 5, sendo 1 o menor interesse e 5 o maior interesse. Considere fatores como engajamento, perguntas feitas e intenção de compra e fale por que da nota.'
      lead_classification = gerar_resposta(lead_classification_question, historico_conversa).gsub("\n", ' ').strip

      conversation_summary_question = 'Faca um resumo de toda essa conversa em um paragrafo'
      conversation_summary = gerar_resposta(conversation_summary_question, historico_conversa).gsub("\n", ' ').strip

      lead_score_question = "#{lead_classification}, Qual foi a nota dada ao lead. Responda com apenas o digito e nada mais"
      lead_score = gerar_resposta(lead_score_question, historico_conversa).gsub("\n", ' ').strip

      @partner_client_lead = @client.partner_client_leads.create(partner: @current_partner,
                                                                lead_classification:, conversation_summary:, lead_score: lead_score.to_i)
      new_lead_received_mail(@partner_client_lead)
    elsif !@partner_client_lead.nil? && !last_message.nil? && last_message.created_at > @partner_client_lead.updated_at

      lead_classification_question = 'Com base na interação, classifique o interesse do lead em uma escala de 1 a 5, sendo 1 o menor interesse e 5 o maior interesse. Considere fatores como engajamento, perguntas feitas e intenção de compra e fale por que da nota.'
      lead_classification = gerar_resposta(lead_classification_question, historico_conversa).gsub("\n", ' ').strip

      conversation_summary_question = 'Faca um resumo de toda essa conversa em um paragrafo'
      conversation_summary = gerar_resposta(conversation_summary_question, historico_conversa).gsub("\n", ' ').strip

      lead_score_question = "#{lead_classification}, Qual foi a nota dada ao lead. Responda com apenas o digito e nada mais"
      lead_score = gerar_resposta(lead_score_question, historico_conversa).gsub("\n", ' ').strip

      @partner_client_lead.update(lead_classification:, conversation_summary:, lead_score: lead_score.to_i)
      new_lead_received_mail(@partner_client_lead)
    end

    render json: PartnerClientLeadSerializer.new(@partner_client_lead).serialized_json, status: :ok
  end

  def new_lead_received_mail(lead)
    PartnerMailer._send_new_lead_received_mail(lead).deliver
  end

  def messages_resume
    pergunta = 'Faca um resumo de toda essa conversa em um paragrafo'
    historico_conversa = messages(@current_partner, @client)
    response = gerar_resposta(pergunta, historico_conversa).gsub("\n", ' ').strip
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
      historico_conversa << { role: 'system', content: "Resumo da conversa anterior: #{@partner_client_lead.conversation_summary}"}

      client.partner_client_messages.by_partner(partner).where('created_at > ?', @partner_client_lead.created_at).order(:created_at).each do |pcm|
        historico_conversa << { role: 'user', content: pcm.message }
        historico_conversa << { role: 'assistant', content: pcm.automatic_response } if pcm.automatic_response
      end
    end

    historico_conversa
  end

  def gerar_resposta(pergunta, historico_conversa)
    return 'Desculpe, não entendi a sua pergunta.' unless pergunta.is_a?(String) && !pergunta.empty?

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

    puts response
    response['choices'][0]['message']['content'].strip
  end

  def set_client
    @client = @current_partner.partner_clients.find(params[:id])
  end
end
