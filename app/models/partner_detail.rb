require 'google/apis/calendar_v3'
require 'google/api_client/client_secrets'

class PartnerDetail < ApplicationRecord
  belongs_to :partner

  def message_content
    "Você é #{name_attendant}, atendente da #{company_name} especializado em #{company_niche} na região de #{served_region}.
    Alinhe sua comunicação com  #{target_audience} da empresa, utilizando o tom de voz #{tone_voice}.
    Os principais objetivos da empresa são #{main_goals}, com metas específicas em #{business_goals}. Os serviços oferecidos são #{company_services}, e os produtos são #{company_products}.
    Estes são nossos canais de marketing, como #{marketing_channels}, e nosso contato #{company_contact}.
    Nosso grande diferencial é #{key_differentials}.
    Identifique as necessidades específicas e os desafios do cliente e faça no máximo uma pergunta por mensagem e mantendo as respostas curtas, não ultrapassando 50 palavras.
    Após entender claramente as necessidades do cliente, proponha o #{company_objectives.join(', ')}. #{observations}.
    Responda 'Peço desculpas, mas não posso fornecer essa informação' quando não souber responder a informação exata.
    E, a menos que instruído de outra forma, você responderá na língua #{preferential_language}."
  end

  def observations
    observation = ''
    if meeting_objective? && !partner.schedule_setting.nil?
      observation << "Caso o cliente solicite um agendamento de reunião, primeiro pergunte pelo e-mail no qual o convite da reunião deve ser enviado e se caso informado, você deve responder exatamente assim substituindo a palavra EMAIL com o e-mail informado: #E-mail informado: EMAIL#.
      Após o cliente informar o e-mail e se aceitar, informe o horário de atendimento que acontece nos dias da semana #{partner.schedule_setting.week_days} das #{partner.schedule_setting.start_time} ate às #{partner.schedule_setting.end_time} com duracao de #{partner.schedule_setting.duration_in_minutes} minutos.
      #{get_events}
      Caso o cliente escolha um dia e horário, você deve responder exatamente assim, preenchendo as lacunas com o dia e horário escolhidos pelo cliente, considerando hoje como sendo #{date_today}: #Agendamento para o dia dd/mm/aaaa às hh:mm#."
    end
    observation
  end

  def date_today
    data_atual = Date.today
    data_formatada = data_atual.strftime('%A, %d de %B de %Y')
    dias_da_semana = {
      'Monday' => 'segunda-feira',
      'Tuesday' => 'terça-feira',
      'Wednesday' => 'quarta-feira',
      'Thursday' => 'quinta-feira',
      'Friday' => 'sexta-feira',
      'Saturday' => 'sábado',
      'Sunday' => 'domingo'
    }
    meses_do_ano = {
      'January' => 'janeiro',
      'February' => 'fevereiro',
      'March' => 'março',
      'April' => 'abril',
      'May' => 'maio',
      'June' => 'junho',
      'July' => 'julho',
      'August' => 'agosto',
      'September' => 'setembro',
      'October' => 'outubro',
      'November' => 'novembro',
      'December' => 'dezembro'
    }
    data_formatada = data_formatada.gsub(/\b(?:#{Regexp.union(dias_da_semana.keys)})\b/, dias_da_semana)
    data_formatada.gsub(/\b(?:#{Regexp.union(meses_do_ano.keys)})\b/, meses_do_ano)
  end

  def meeting_objective?
    company_objectives.include?('Agendar uma reunião')
  end

  def find_agenda(client)
    puts '###################Buscando agenda#######################'

    return if client.nil?

    desired_calendar_name = 'SacGPT agenda'
    calendar_list = client.list_calendar_lists
    calendar_list.items.find { |calendar| calendar.summary == desired_calendar_name }
  end

  def get_agenda
    puts '###########################Montando Agenda#############################'

    Google::Apis::CalendarV3::Calendar.new(summary: 'SacGPT agenda', time_zone: 'America/Sao_Paulo')
  end

  def create_agenda(client)
    puts '##########################Criando agenda##########################'

    return if client.nil?

    calendar = get_agenda
    begin
      agenda = client.insert_calendar(calendar)
    rescue StandardError => e
      puts e
      errors.add(:base, 'Fail to create Agenda.')
      throw :abort
    end
    puts 'Sucess Agenda created'
    agenda
  end

  def get_events
    return '' unless partner.present? && partner.access_token.present? && partner.refresh_token.present?

    client = get_google_calendar_client(partner)
    agenda = find_agenda(client)

    if agenda.nil? || partner.schedule_setting.google_agenda_id.nil? || agenda.id != partner.schedule_setting.google_agenda_id
      agenda = create_agenda(client)
      partner.schedule_setting.update(google_agenda_id: agenda.id)
    end

    response = client.list_events(partner.schedule_setting.google_agenda_id)

    if response.items.empty?
      ''
    else
      date_times = response.items.map { |event| event.start.date_time }
      "Esses são os horários já reservados #{date_times.join(', ')}. Caso o cliente escolha um desses dias e horários, peça para escolher um outro horário."
    end
  end

  def get_google_calendar_client(partner)
    client = Google::Apis::CalendarV3::CalendarService.new
    return unless partner.present? && partner.access_token.present? && partner.refresh_token.present?

    secrets = Google::APIClient::ClientSecrets.new({
                                                     'web' => {
                                                       'access_token' => partner.access_token,
                                                       'refresh_token' => partner.refresh_token,
                                                       'client_id' => ENV['GOOGLE_CLIENT_ID'],
                                                       'client_secret' => ENV['GOOGLE_CLIENT_SECRET']
                                                     }
                                                   })
    begin
      client.authorization = secrets.to_authorization
      client.authorization.grant_type = 'refresh_token'
      if partner.expires_at.nil? || DateTime.now >= partner.expires_at
        client.authorization.refresh!
        partner.update(
          access_token: client.authorization.access_token,
          refresh_token: client.authorization.refresh_token,
          expires_at: client.authorization.expires_at
        )
      end
    rescue StandardError => e
      puts e
      errors.add(:base, 'Your token has been expired. Please login again with google.')
      throw :abort
    end
    client
  end
end
