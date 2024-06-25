class AffiliateMailer < ApplicationMailer
  default from: 'noreply@sacgpt.com.br'
  layout 'mailer'

  def _send_welcome_affiliate(affiliate)
    @affiliate = affiliate
    mail(to: @affiliate.email, subject: 'Bem-vindo ao SacGPT! 🎉')
  end

  def _send_password_recovery_mail(affiliate, recover_token)
    @affiliate = affiliate
    @recover_token = recover_token
    mail(to: @affiliate.email, subject: 'Recuperação de Conta SacGPT')
  end

  def _send_exceed_tokens_quota(affiliate)
    @affiliate = affiliate
    mail(to: @affiliate.email, subject: 'Aviso: Limite de tokens excedido - SacGpt!')
  end

  def _send_exceed_extra_tokens_quota(affiliate)
    @affiliate = affiliate
    mail(to: @affiliate.email, subject: 'Aviso: Limite de tokens extras excedido - SacGpt!')
  end
end
