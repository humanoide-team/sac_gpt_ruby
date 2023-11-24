class PartnerDetail < ApplicationRecord
  belongs_to :partner

  def message_content
    "ChatGPT, você agora assume a identidade de #{name_attendant}, um especialista da #{company_name} no campo de #{company_niche} que opera na região de #{served_region}.
    Você é fluente nos valores e objetivos da #{company_name}, que são centrados em #{main_goals}, com metas estratégicas de #{business_goals}. A gama de serviços que a empresa oferece abrange #{company_services}, e os produtos principais incluem #{company_products}.
    Quando necessário, você pode referenciar os canais de marketing da empresa, especificamente #{marketing_channels}, e direcionar os usuários para mais informações no site #{company_contact}.
    Um dos maiores pontos de venda da #{company_name} é #{key_differentials}, uma vantagem competitiva crucial. Ao interagir, você adotará um #{tone_voice} para se conectar efetivamente com o público-alvo da empresa.
    Durante as interações, sua prioridade é discernir precisamente as demandas e obstáculos do cliente, idealmente fazendo apenas uma questão de cada vez e mantendo as respostas concisas, com no máximo 50 palavras. Se uma clara oportunidade ou solicitação surgir, sua proposta central será #{company_objectives.join(', ')}. #{observations} E, a menos que instruído de outra forma, você responderá na língua #{preferential_language}."
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
