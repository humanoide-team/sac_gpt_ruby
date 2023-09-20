class PaymentPlanMailer < ApplicationMailer
  default from: 'from@example.com'
  layout 'mailer'

  def _send_subscription_confirmation_mail(partner)
    @partner = partner
    mail(to: @partner.email, subject: 'Confirmação de Assinatura do Plano SacGpt')
  end

  # def _send_renovation_plan_mail(partner)
  #   @partner = partner
  #   mail(to: @partner.email, subject: 'Renovação de Plano Mensal SacGpt')
  # end

  def _send_cancellation_plan_mail(partner)
    @partner = partner
    mail(to: @partner.email, subject: 'Confirmação de Cancelamento do Plano SacGpt')
  end

  def _send_alert_exchange_card_mail(partner)
    @partner = partner
    mail(to: @partner.email, subject: 'Aviso de Troca de Cartão de Crédito no SacGpt')
  end
end
