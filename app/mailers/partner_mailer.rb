class PartnerMailer < ApplicationMailer
  default from: 'from@example.com'
  layout 'mailer'

  def _send_welcome_partner(partner)
    @partner = partner
    mail(to: @partner.email, subject: 'Bem-vindo ao SacGpt! 🎉')
  end

  def _send_password_recovery_mail(partner, recover_token)
    @partner = partner
    @recover_token = recover_token
    mail(to: @partner.email, subject: 'Recuperação de Conta SacGpt')
  end

  def _send_new_lead_received_mail(lead)
    @lead = lead
    @partner = lead.partner
    mail(to: @partner.email, subject: 'Nova Lead Recebida: [Nome da Lead] - SacGpt')
  end
end
