class PartnerClientMessage < ApplicationRecord
  belongs_to :partner
  belongs_to :partner_client

  scope :by_partner_id, ->(partner_id) { where(partner_id: partner_id) }
  scope :by_partner, ->(partner) { where(partner: partner) }

  after_create :new_lead_received_mail

  def new_lead_received_mail
    return unless partner_client.partner_client_messages.by_partner(partner).size <= 1

    PartnerMailer._send_new_lead_received_mail(self).deliver
    partner.notifications.create(
      title: 'Novo Lead Recebido',
      description: 'Gostaríamos de informar que uma novo lead foi recebida através da plataforma SacGPT. Estamos entusiasmados em compartilhar essa atualização com você.',
      notification_type: :new_lead_received,
      metadata: {
        partner_client_message: id,
        partner_client: partner_client
      }
    )
  end
end
