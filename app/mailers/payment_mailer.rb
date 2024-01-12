class PaymentMailer < ApplicationMailer
  default from: 'noreply@sacgpt.com.br'
  layout 'mailer'

  def _send_payment_confirmation_mail(payment, partner, credit_card)
    @partner = partner
    @payment = payment
    @credit_card = credit_card
    mail(to: @partner.email, subject: 'Confirmação de Pagamento')
  end
end
