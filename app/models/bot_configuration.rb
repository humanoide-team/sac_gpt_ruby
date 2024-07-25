class BotConfiguration < ApplicationRecord
  belongs_to :affiliate
  belongs_to :prospect_card

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
    content << " Estes são nossos canais de marketing, como #{marketing_channels}" if marketing_channels.present?
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
    observation << 'Ao receber uma solicitação de agendamento, responda exatamente com : Não foi possível marcar a reunião no momento, nossa equipe entrará em contato direto!'
    observation
  end

  def details_filled?
    name_attendant.present? && company_name.present? && company_niche.present?
  end
end
