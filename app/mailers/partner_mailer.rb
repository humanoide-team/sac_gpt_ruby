class PartnerMailer < ApplicationMailer
  default from: 'from@example.com'
  layout 'mailer'

  def _send_welcome_partner(partner)
    @partner = partner
    mail(to: @partner.email, subject: 'Bem-vindo ao SacGpt! 🎉')
  end
end
