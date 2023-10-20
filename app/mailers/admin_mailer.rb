class AdminMailer < ApplicationMailer
  default from: 'from@example.com'
  layout 'mailer'

  def _send_weekly_summary(admin)
    @admin = admin
    mail(to: @admin.email, subject: 'Resumo Semanal - SacGPT')
  end

  def _send_recovery_password(admin)
    @admin = admin
    mail(to: @admin.email, subject: 'Recuperação de Senha - SacGPT')
  end
end
