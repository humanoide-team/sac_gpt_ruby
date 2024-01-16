class PartnerMailer < ApplicationMailer
  default from: 'noreply@sacgpt.com.br'
  layout 'mailer'

  def _send_welcome_partner(partner)
    @partner = partner
    mail(to: @partner.email, subject: 'Bem-vindo ao SacGPT! 🎉')
  end

  def _send_password_recovery_mail(partner, recover_token)
    @partner = partner
    @recover_token = recover_token
    mail(to: @partner.email, subject: 'Recuperação de Conta SacGPT')
  end

  def _send_new_lead_received_mail(lead)
    @lead = lead
    @partner = lead.partner
    @client = lead.partner_client
    mail(to: @partner.email, subject: 'Novo Lead Recebido - SacGPT')
  end

  def _send_support_mail(contact, subject, body)
    @body = body
    mail(to: 'equipe.sacgpt@sacgpt.com.br', subject: subject, from: contact)
  end

  def _send_exceed_tokens_quota(partner)
    @partner = partner
    mail(to: @partner.email, subject: 'Sua ultrapassou sua cota de tokens - SacGPT')
  end

  def _send_almost_exceed_tokens_quota(partner)
    @partner = partner
    mail(to: @partner.email, subject: 'Sua cota de tokens esta quase acabando - SacGPT')
  end

  def _send_half_tokens_quota(partner)
    @partner = partner
    mail(to: @partner.email, subject: 'Sua vc atiginiu metade da sua cota de tokens - SacGPT')
  end

  def _send_exceed_extra_tokens_quota(partner)
    @partner = partner
    mail(to: @partner.email, subject: 'Sua ultrapassou sua cota de tokens - SacGPT')
  end

  def _send_almost_exceed_extra_tokens_quota(partner)
    @partner = partner
    mail(to: @partner.email, subject: 'Sua cota de tokens esta quase acabando - SacGPT')
  end

  def _send_half_extra_tokens_quota(partner)
    @partner = partner
    mail(to: @partner.email, subject: 'Sua vc atiginiu metade da sua cota de tokens - SacGPT')
  end
end
