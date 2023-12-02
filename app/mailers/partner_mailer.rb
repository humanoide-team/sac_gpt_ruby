class PartnerMailer < ApplicationMailer
  default from: 'noreply@sacgpt.com.br'
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
    @client = lead.partner_client
    mail(to: @partner.email, subject: 'Novo Lead Recebido - SacGpt')
  end
end
