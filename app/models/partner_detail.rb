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
    if meeting_objective?
      observation << "Caso o cliente solicite uma agendamento de reuniao informe o horario de atendimento da segunda a sexta das 9hrs as 12hrs e das 13hrs as 17hrs, caso o cliente escolha um dia e horario vc deve responder exatamente assim prenchendo as lacunas com o dia e horario escolhido pelo cliente considerando hoje como sendo #{date_today}: #Agendamento para o dia dd/mm/yyyy as hh:mm#"
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
end
