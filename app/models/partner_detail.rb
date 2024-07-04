require 'google/apis/calendar_v3'
require 'google/api_client/client_secrets'

class PartnerDetail < ApplicationRecord
  belongs_to :partner
  has_many :prompt_files

  # after_create :create_open_ai_partner_assistent
  # after_update :update_assistent

  def message_content
    content = ''
    content << "Você é #{name_attendant}, atendente da #{company_name} especializado em #{company_niche}. "
    content << "na região de #{served_region}, " if served_region.present?
    content << if tone_voice.present?
                 "utilize o tom de voz #{tone_voice.join(', ')}."
               else
                 'utilize o tom de voz neutro.'
               end
    content << " Os serviços oferecidos são #{company_services}, " if company_services.present?
    content << "e os produtos são #{company_products}." if company_products.present?
    content << " Estes são nossos canais de marketing, como #{social_channels}" if social_channels.present?
    content << " e nosso contato #{company_contact}." if company_contact.present?
    content << " Nosso grande diferencial é #{key_differentials}. " if key_differentials.present?
    content << " E, a menos que instruído de outra forma, você responderá na língua #{preferential_language.present? ? preferential_language : 'PT-BR'}."
    content << ' Identifique as necessidades específicas e os desafios do cliente e faça no máximo uma pergunta por mensagem e mantendo as respostas curtas, não ultrapassando 50 palavras e responda com a formatação apropriada para o WhatsApp.'
    if company_objectives.present?
      content << " Após entender claramente as necessidades do cliente, proponha o #{company_objectives.join(', ')}. "
    end
    content << " Quando alguem solicitar o catálogo envie o link #{catalog_link}." if catalog_link.present?
    content << " Quando não souber responder uma informação que o cliente solicitou responda: 'Peço desculpas, mas não tenho acesso a essa informação, no que mais poderia te ajudar?'"
    content << " Quando não conseguir entender o que o cliente escreveu responda: 'Peço desculpas, mas não consegui entender, poderia repetir?'"
    content
  end

  def observations
    observation = ''
    if !partner.schedule_setting.nil?
      observation << "Ao receber uma solicitação de agendamento, inicie com: 'Por favor, informe seu e-mail para o envio do convite da reunião.', se o e-mail for fornecido, responda exatamente com: '#E-mail informado: EMAIL#. Obrigado!' substituindo a palavra EMAIL pelo email fornecido." +
                     "Caso o cliente se recuse a enviar ou pergunte a necessidade responda: 'Precisamos do seu e-mail para prosseguir com o agendamento!'." +
                     "Com o e-mail enviado pelo cliente, informe os horarios de atendimento: 'Atendemos de #{partner.schedule_setting.week_days}, das #{partner.schedule_setting.start_time} às #{partner.schedule_setting.end_time}, sessões de #{partner.schedule_setting.duration_in_minutes} min. Qual horário prefere?'." +
                     "#{get_events}" +
                     "Se não escolherem imediatamente, reitere: 'Por favor, escolha um horário disponível para confirmarmos." +
                     "Quando um horário for escolhido, responda exatamente com: '#Agendamento para o dia dd/mm/aaaa às hh:mm#. Aguardamos você!' subistituindo dd/mm/aaaa e hh:mm com a data e o horario pelo cliente, se atente no formato de data e hora do exemplo." +
                     'Se necessário, não hesite em repetir um passo ou informação para clarificação ou para garantir a completude do processo.'
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

    if agenda.nil?
      agenda = create_agenda(client)
      partner.schedule_setting.update(google_agenda_id: agenda.id)
    elsif partner.schedule_setting.google_agenda_id.nil? || agenda.id != partner.schedule_setting.google_agenda_id
      partner.schedule_setting.update(google_agenda_id: agenda.id)
    end

    response = client.list_events(partner.schedule_setting.google_agenda_id)

    if response.items.empty?
      "Considere o dia de hoje como sendo #{date_today}"
    else
      date_times = response.items.map { |event| event.start.date_time }
      "Esses são os horários já reservados: #{date_times.join(', ')}. Caso o cliente escolha um desses dias e horários, peça para escolher um outro horário. Considere o dia de hoje como sendo #{date_today}"
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

  def social_channels
    channels = []
    channels << twitter_x_link if twitter_x_link
    channels << youtube_link if youtube_link
    channels << facebook_link if facebook_link
    channels << instagram_link if instagram_link

    channels.join(', ')
  end

  def create_open_ai_partner_assistent
    partner.create_partner_assistent
  end

  def update_assistent
    partner.partner_assistent.update_assistent
  end

  def connected_with_google
    partner.access_token.present? && partner.refresh_token.present?
  end

  def details_filled?
    name_attendant.present? && company_name.present? && company_niche.present?
  end
end
