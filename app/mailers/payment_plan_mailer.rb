class PaymentPlanMailer < ApplicationMailer
  default from: 'from@example.com'
  layout 'mailer'

  def _send_subscription_confirmation_mail(subscription)
    @subscription = subscription
    mail(to: @partner.email, subject: 'Confirmação de Assinatura do Plano SacGPT')
  end

  # def _send_renovation_plan_mail(partner)
  #   @partner = partner
  #   mail(to: @partner.email, subject: 'Renovação de Plano Mensal SacGPT')
  # end

  def _send_cancellation_plan_mail(subscription)
    @subscription = subscription
    mail(to: @partner.email, subject: 'Confirmação de Cancelamento do Plano SacGPT')
  end

  def _send_alert_exchange_card_mail(credit_card, partner)
    @partner = partner
    @credit_card = credit_card
    mail(to: @partner.email, subject: 'Aviso de Troca de Cartão de Crédito no SacGPT')
  end
end
