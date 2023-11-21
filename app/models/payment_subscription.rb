require 'securerandom'

class PaymentSubscription < ApplicationRecord
  belongs_to :partner
  belongs_to :credit_card
  belongs_to :payment_plan

  before_create :create_galax_pay_payment_subscription

  before_destroy :cancel_galax_pay_payment_subscription

  after_create :subscription_confirmation_mail

  after_destroy :cancellation_plan_mail

  enum main_payment_method_id: {
    creditcard: 0
  }

  enum status: {
    active: 0,
    canceled: 1,
    closed: 2,
    stopped: 3
  }

  def create_galax_pay_payment_subscription
    uuid = SecureRandom.uuid

    galax_pay_payment_subscription = GalaxPayClient.create_payment_subscription(uuid, payment_plan.galax_pay_my_id, first_pay_day_date, additional_info,
                                                          main_payment_method_id, partner, credit_card.galax_pay_my_id)

    if galax_pay_payment_subscription.nil?
      errors.add(:base, 'Erro ao criar Inscricao')
      throw :abort
    else
      self.galax_pay_id = galax_pay_payment_subscription['galaxPayId'].to_i
      self.status = galax_pay_payment_subscription['status']
      self.payment_link = galax_pay_payment_subscription['paymentLink']
      self.galax_pay_my_id = galax_pay_payment_subscription['myId']
    end
  end

  def cancel_galax_pay_payment_subscription
    response = GalaxPayClient.cancel_payment_subscription(galax_pay_id)

    return unless response == true

    update_attribute(:status, 'canceled')
    cancellation_plan_mail
  end

  def subscription_confirmation_mail
    PaymentPlanMailer._send_subscription_confirmation_mail(self, partner).deliver
    partner.notifications.create(
      title: 'Confirmação de Assinatura do Plano SacGPT',
      description: "É com grande satisfação que confirmamos a sua assinatura do #{payment_plan.name} no SacGPT!",
      notification_type: :subscription_confirmation,
      metadata: {
        payment_subscription: id
      }
    )
  end

  def cancellation_plan_mail
    PaymentPlanMailer._send_cancellation_plan_mail(self, partner).deliver
    partner.notifications.create(
      title: 'Confirmação de Cancelamento do Plano SacGPT',
      description: 'Recebemos a sua solicitação de cancelamento do plano. Lamentamos ver você partir e gostaríamos de agradecer por ter sido parte da nossa comunidade.',
      notification_type: :cancellation_plan,
      metadata: {
        payment_subscription: id
      }
    )
  end
end
