require 'securerandom'

class PaymentSubscription < ApplicationRecord
  belongs_to :partner
  belongs_to :credit_card
  belongs_to :payment_plan
  has_many :revenues, as: :partner_transaction, dependent: :delete_all

  before_create :create_galax_pay_payment_subscription

  before_destroy :cancel_galax_pay_payment_subscription

  after_create :subscription_confirmation_mail

  after_destroy :cancellation_plan_mail

  after_save :create_affiliate_revenue

  enum main_payment_method_id: {
    creditcard: 0
  }

  enum status: {
    active: 0,
    canceled: 1,
    closed: 2,
    stopped: 3,
    waitingPayment: 4,
    inactive: 5
  }

  def update_galax_pay_payment_subscription_status
    return if galax_pay_id.nil?

    galax_pay_payment_subscription = GalaxPayClient.list_payment_subscription(galax_pay_id)

    if galax_pay_payment_subscription.nil?
      errors.add(:base, 'Erro ao listar Inscricao verifique os daddos')
      throw :abort
    else
      return if galax_pay_payment_subscription['status'] == self.status

      self.status = galax_pay_payment_subscription['status']
      self.save
    end
  end

  def create_galax_pay_payment_subscription
    uuid = SecureRandom.uuid

    galax_pay_payment_subscription = GalaxPayClient.create_payment_subscription(uuid, payment_plan.galax_pay_my_id, first_pay_day_date, additional_info,
                                                                                main_payment_method_id, partner, credit_card.galax_pay_my_id)

    if galax_pay_payment_subscription.nil?
      errors.add(:base, 'Erro ao criar Inscricao verifique os daddos')
      throw :abort
    else
      self.galax_pay_id = galax_pay_payment_subscription['galaxPayId'].to_i
      self.status = galax_pay_payment_subscription['status']
      self.payment_link = galax_pay_payment_subscription['paymentLink']
      self.galax_pay_my_id = galax_pay_payment_subscription['myId']
      self.max_token_count = payment_plan.max_token_count
    end
  end

  def edit_payment_method_galax_pay_payment_subscription(credit_card)
    galax_pay_payment_subscription = GalaxPayClient.edit_payment_subscription_credit_card(galax_pay_id,
                                                                                          payment_plan.plan_price_value.to_i, payment_plan.plan_price_payment, credit_card.galax_pay_my_id)

    return false if galax_pay_payment_subscription.nil?

    update_attribute(:credit_card_id, credit_card.id)
  end

  def cancel_galax_pay_payment_subscription
    response = GalaxPayClient.cancel_payment_subscription(galax_pay_id)

    return unless response == true

    update_attribute(:status, 'canceled')
    update_attribute(:credit_card_id, nil)

    cancellation_plan_mail
  end

  def subscription_confirmation_mail
    PaymentPlanMailer._send_subscription_confirmation_mail(self, partner, credit_card).deliver
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

  def next_payment_day
    today = Date.today
    year = today.year
    month = today.month
    payment_day = first_pay_day_date.day

    if today <= Date.new(year, month, payment_day)
      Date.new(year, month, payment_day)
    else

      next_month = month == 12 ? 1 : month + 1
      next_year = month == 12 ? year + 1 : year
      Date.new(next_year, next_month, payment_day)
    end
  end

  def self.top_plan_by_subs
    top_plan_by_subs = PaymentSubscription.group(:payment_plan_id).count.max_by { |_, count| count }
    return unless top_plan_by_subs

    payment_plan_id, subscriptions_count = top_plan_by_subs
    payment_plan = PaymentPlan.find(payment_plan_id)
    { payment_plan: payment_plan, subscriptions_count: subscriptions_count }
  end

  def create_affiliate_revenue
    return if partner.affiliate.nil?

    return unless status == 'active'

    Revenue.create(partner_transaction: self, partner:, affiliate: partner.affiliate, value: payment_plan.plan_price_value.to_i * (partner.affiliate.revenue_percentage / 100.0))
  end
end
