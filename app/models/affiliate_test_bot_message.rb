class AffiliateTestBotMessage < ApplicationRecord
  belongs_to :affiliate

  after_create :generate_automatic_response

  def generate_automatic_response
    return if affiliate.bot_configuration.nil? || !affiliate.bot_configuration_filled?

    return unless affiliate.active

    return unless affiliate.active

    @affiliate_test_bot_lead = affiliate.affiliate_test_bot_lead

    @affiliate_test_bot_lead = AffiliateTestBotLead.create(affiliate:) if @affiliate_test_bot_lead.nil?

    Thread.new { aguardar_e_enviar_resposta }
  end

  def aguardar_e_enviar_resposta
    sleep(10)

    last_response = affiliate.affiliate_test_bot_messages.order(:created_at).last
    return if !last_response.nil? && last_response.created_at > created_at

    bot_configuration_prompt = affiliate.bot_configuration.message_content

    historico_conversa = [{ role: 'system', content: bot_configuration_prompt }]

    unless affiliate.bot_configuration.observations.empty?
      historico_conversa << { role: 'system', content: affiliate.bot_configuration.observations }
    end

    messages = affiliate.bot_messages_history

    generate_message_history(messages, historico_conversa)

    text_response = gerar_resposta(message, historico_conversa)
    # text_response = identificar_agendamento(text_response)

    update(automatic_response: text_response)
  end

  def gerar_resposta(pergunta, historico_conversa)
    return 'Desculpe, não entendi a sua pergunta.' unless pergunta.is_a?(String) && !pergunta.empty?

    begin
      response = OpenAiClient.text_generation(pergunta, historico_conversa, ENV['OPENAI_MODEL_LEAD'])
      if response != 'Falha em gerar resposta'
        token_cost = calculate_token(response['usage']).round
        affiliate.calculate_usage(token_cost)
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

  def generate_message_history(messages, historico_conversa)
    messages.each do |pcm|
      historico_conversa << { role: 'user', content: pcm.message }
      historico_conversa << { role: 'assistant', content: pcm.automatic_response } if pcm.automatic_response
    end
  end

  def identificar_agendamento(response)
    response = identificar_email(response)

    regex = %r{#Agendamento para o dia (\d{2}/\d{2}/\d{4}) às (\d{2}:\d{2})#}
    match_data = response.match(regex)

    return response unless match_data

    if !affiliate.connected_with_google || affiliate.schedule_setting.nil?
      return 'Não foi possível marcar a reunião no momento, e necessario configurar o agendamento!'
    end

    data_hora_string = "#{match_data[1]} #{match_data[2]}"
    data_hora = DateTime.strptime(data_hora_string, '%d/%m/%Y %H:%M')
    schedule = Schedule.create(summary: 'Agendamento de reuniao!', description: "Agendamento para o dia #{match_data[1]} as #{match_data[2]} com o cliente #{affiliate.name}", date_time_start: data_hora + 3.hours,
                               date_time_end: data_hora + affiliate.schedule_setting.duration_in_minutes.minutes + affiliate.schedule_setting.interval_minutes.minutes + 3.hours, affiliate_id: affiliate.id)

    if schedule
      response
    else
      'Não foi possível marcar a reunião no momento, nossa equipe entrará em contato direto'
    end
  end

  def identificar_email(response)
    regex = /#E-mail informado: ([\w+\-.]+@[a-z\d\-.]+\.[a-z]+)#/
    match_data = response.match(regex)

    return response unless match_data

    if @affiliate_test_bot_lead.update(test_bot_mail: match_data[1])
      response
    else
      'Nao foi possivel identificar o seu email'
    end
  end

  def calculate_token(usage)
    input = usage['prompt_tokens']
    output = usage['completion_tokens']
    input + output
  end
end
