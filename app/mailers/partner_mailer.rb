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

  def _send_subscription_confirmation_mail(partner)
    @partner = partner
    mail(to: @partner.email, subject: 'Confirmação de Assinatura do Plano SacGpt')
  end

  def _send_renovation_plan_mail(partner)
    @partner = partner
    mail(to: @partner.email, subject: 'Renovação de Plano Mensal SacGpt')
  end

  def _send_cancellation_plan_mail(partner)
    @partner = partner
    mail(to: @partner.email, subject: 'Confirmação de Cancelamento do Plano SacGpt')
  end

  def _send_alert_exchange_card_mail(partner)
    @partner = partner
    mail(to: @partner.email, subject: 'Aviso de Troca de Cartão de Crédito no SacGpt')
  end

  def _send_new_lead_received_mail(partner)
    @partner = partner
    mail(to: @partner.email, subject: 'Nova Lead Recebida: [Nome da Lead] - SacGpt')
  end
end
