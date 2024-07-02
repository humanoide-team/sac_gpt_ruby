class PartnerTestBotMessage < ApplicationRecord
  belongs_to :partner

  after_create :generate_automatic_response

  def generate_automatic_response
    return if partner.partner_detail.nil? || !partner.partner_details_filled?

    return unless partner.active

    return unless partner.active

    @partner_test_bot_lead = partner.partner_test_bot_lead

    @partner_test_bot_lead = PartnerTestBotLead.create(partner:) if @partner_test_bot_lead.nil?

    Thread.new { aguardar_e_enviar_resposta }
  end

  def aguardar_e_enviar_resposta
    sleep(10)

    last_response = partner.partner_test_bot_messages.order(:created_at).last
    return if !last_response.nil? && last_response.created_at > created_at

    partner_detail_prompt = partner.partner_detail.message_content

    historico_conversa = [{ role: 'system', content: partner_detail_prompt }]

    unless partner.partner_detail.observations.empty?
      historico_conversa << { role: 'system', content: partner.partner_detail.observations }
    end

    messages = partner.bot_messages_history

    generate_message_history(messages, historico_conversa)

    text_response = gerar_resposta(message, historico_conversa)

    update(automatic_response: text_response)
  end

  def gerar_resposta(pergunta, historico_conversa)
    return 'Desculpe, não entendi a sua pergunta.' unless pergunta.is_a?(String) && !pergunta.empty?

    begin
      response = OpenAiClient.text_generation(pergunta, historico_conversa, ENV['OPENAI_MODEL'])
      if response != 'Falha em gerar resposta'
        token_cost = calculate_token(response['usage']).round
        partner.calculate_usage(token_cost)
        @partner_test_bot_lead.increase_token_count(token_cost)
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

  def generate_message_history(messages, historico_conversa)
    messages.each do |pcm|
      historico_conversa << { role: 'user', content: pcm.message }
      historico_conversa << { role: 'assistant', content: pcm.automatic_response } if pcm.automatic_response
    end
  end

  def calculate_token(usage)
    input = usage['prompt_tokens']
    output = usage['completion_tokens']
    input + output
  end
end
