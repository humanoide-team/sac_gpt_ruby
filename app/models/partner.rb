require 'securerandom'

class Partner < ApplicationRecord
  acts_as_paranoid

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable

  attr_accessor :current_password, :auth_token, :expires_at

  extend FriendlyId
  friendly_id :name_slug, use: :slugged

  has_one_base64_attached :avatar
  belongs_to :affiliate, optional: true
  has_one :partner_detail, dependent: :destroy
  has_one :schedule_setting, dependent: :destroy
  has_one :conversation_thread_, dependent: :destroy
  has_one :partner_assistent, dependent: :destroy
  has_one :partner_test_bot_lead, dependent: :destroy
  has_many :partner_client_messages, dependent: :destroy
  has_many :partner_clients, dependent: :destroy
  has_many :partner_payments, dependent: :destroy
  has_many :credit_cards, dependent: :destroy
  has_many :payment_subscriptions, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :partner_client_leads, dependent: :destroy
  has_many :partner_client_conversation_infos, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :montly_usage_histories, dependent: :destroy
  has_many :extra_tokens, dependent: :destroy
  has_many :schedules, dependent: :destroy
  has_many :partner_test_bot_messages, dependent: :destroy

  validates :name, :email, presence: true, on: :create
  validates :password_confirmation, presence: true, on: :create

  accepts_nested_attributes_for :partner_detail, reject_if: :all_blank

  after_save :generate_instance_key, unless: :instance_key?

  after_create :send_welcome_mail

  after_create :create_free_subscription

  before_update :create_galax_pay_client, unless: :galax_pay_id?

  after_update :generate_instance_key, if: :service_number_is_updated?

  before_destroy :cancel_active_subscription

  def send_welcome_mail
    PartnerMailer._send_welcome_partner(self).deliver
    notifications.create(
      title: 'Bem-vindo ao SacGPT! 🎉',
      description: 'É com grande satisfação que damos as boas-vindas à família SacGPT! Agradecemos por escolher a nossa plataforma.',
      notification_type: :welcome_partner
    )
  end

  def password_recovery_mail
    PartnerMailer._send_password_recovery_mail(self, generate_recover_password_key).deliver
  end

  def name_slug
    return unless name.present?

    [name.parameterize.to_s]
  end

  def generate_key
    SecureRandom.random_bytes(32)
  end

  def encrypted_data(data, key)
    @verifier = ActiveSupport::MessageVerifier.new(key)
    @verifier.generate(data, expires_in: 7.days)
  end

  def generate_recover_password_key
    encrypted_data(email, ENV['ENCRYPTION_KEY'])
  end

  def generate_instance_key
    token = "#{name_slug[0]}-#{id}"

    update_attribute(:instance_key, token)
  end

  def create_galax_pay_client
    return unless profile_filled?

    uuid = SecureRandom.uuid
    galax_pay_client = GalaxPayClient.create_client(uuid, name, document, email, contact_number)
    if galax_pay_client.nil? || galax_pay_client["error"].present?
      errors.add(:base, galax_pay_client["error"])
      throw :abort
    else
      self.galax_pay_id = galax_pay_client['galaxPayId'].to_i
      self.galax_pay_my_id = galax_pay_client['myId']
    end
  end

  def create_free_subscription
    plan = PaymentPlan.find_by(name: 'Plano Gratuito')

    return if plan.nil?

    if payment_subscriptions.build(first_pay_day_date: DateTime.now, additional_info: 'Plano Gratuito', payment_plan: plan, status: :active).save
      self.active = true
      self.wpp_connected = false
      self.save
    end
  end

  def list_transactions(status, start_at, limit)
    GalaxPayClient.get_transactions_by_client(galax_pay_id, status, start_at, limit)
  end

  def service_number_is_updated?
    saved_change_to_service_number?
  end

  def bot_messages_history
    partner_test_bot_messages.order(:created_at)
  end

  def calculate_usage(tokens)
    return if current_subscription.nil?

    current_mothly_history

    return if current_mothly_history.nil?

    current_mothly_history.subtract_tokens(tokens)

    current_mothly_token = current_mothly_history.token_count

    current_mothly_extra_token = current_mothly_history.extra_token_count

    total_mothly_token = current_mothly_token + current_mothly_extra_token

    plan_max_token = current_subscription.max_token_count

    if active && current_mothly_token.zero? && current_mothly_extra_token.zero?
      update_attribute(:active, false)
      unless current_mothly_history.exceed_mail
        PartnerMailer._send_exceed_tokens_quota(self).deliver
        notifications.create(
          title: 'Aviso: Limite de tokens excedido - SacGpt!',
          description: 'Você excedeu o limite de tokens disponíveis para este mês, por favor, atualize seu plano para continuar utilizando o serviço.',
          notification_type: :extra_token
        )
        current_mothly_history.update(exceed_mail: true)
      end
    elsif active && ((current_mothly_token / plan_max_token.to_f) * 100) <= 10 && current_mothly_extra_token.zero?
      unless current_mothly_history.almost_exceed
        PartnerMailer._send_almost_exceed_tokens_quota(self).deliver
        notifications.create(
          title: 'Aviso Urgente: 90% da Cota Atingida - SacGpt!',
          description: 'Você atingiu 90% da cota de tokens disponíveis para este mês, por favor, atualize seu plano para continuar utilizando o serviço.',
          notification_type: :extra_token
        )
        current_mothly_history.update(almost_exceed: true)
      end
    elsif active && ((current_mothly_token / plan_max_token.to_f) * 100) <= 50 && current_mothly_extra_token.zero?
      unless current_mothly_history.half_exceed
        PartnerMailer._send_half_tokens_quota(self).deliver
        notifications.create(
          title: 'Aviso: 50% da Cota Atingida - SacGpt!',
          description: 'Você atingiu 50% da cota de tokens disponíveis para este mês, por favor, atualize seu plano para continuar utilizando o serviço.',
          notification_type: :extra_token
        )
        current_mothly_history.update(half_exceed: true)
      end
    elsif active && total_mothly_token.zero?
      update_attribute(:active, false)
      unless current_mothly_history.exceed_extra_token_mail
        PartnerMailer._send_exceed_extra_tokens_quota(self).deliver
        notifications.create(
          title: 'Aviso: Limite de tokens extras excedido - SacGpt!',
          description: 'Você excedeu o limite de tokens extras disponíveis para este mês, por favor, atualize seu plano para continuar utilizando o serviço.',
          notification_type: :extra_token
        )
        current_mothly_history.update(exceed_extra_token_mail: true)
      end
    elsif active && !current_mothly_extra_token.zero? && ((current_mothly_token / (plan_max_token + current_mothly_extra_token).to_f) * 100) <= 10
      unless current_mothly_history.extra_token_almost_exceed
        PartnerMailer._send_almost_exceed_extra_tokens_quota(self).deliver
        notifications.create(
          title: 'Aviso Urgente: 90% da cota extra atingida - SacGpt!',
          description: 'Você atingiu 90% da cota extra de tokens disponíveis para este mês, por favor, atualize seu plano para continuar utilizando o serviço.',
          notification_type: :extra_token
        )
        current_mothly_history.update(extra_token_almost_exceed: true)
      end
    elsif active && !current_mothly_extra_token.zero? && ((current_mothly_token / (plan_max_token + current_mothly_extra_token).to_f) * 100) <= 50
      unless current_mothly_history.extra_token_half_exceed
        PartnerMailer._send_half_extra_tokens_quota(self).deliver
        notifications.create(
          title: 'Aviso: 50% da cota extra de tokens atingida - SacGpt!',
          description: 'Você atingiu 50% da cota extra de tokens disponíveis para este mês, por favor, atualize seu plano para continuar utilizando o serviço.',
          notification_type: :extra_token
        )
        current_mothly_history.update(extra_token_half_exceed: true)
      end
    end
  end

  def current_mothly_history
    subscription = current_subscription

    update_attribute(:active, false) if subscription.nil? || current_plan.nil?

    return unless subscription && current_plan

    montly_usage = montly_usage_histories.last
    today = Date.today
    month_payment_day = Date.new(today.year, today.month, subscription.first_pay_day_date.day)

    if montly_usage.nil?
      montly_usage_histories.create(period: month_payment_day,
                                    token_count: current_plan.max_token_count,
                                    extra_token_count: 0)
    elsif !montly_usage.nil? && today < montly_usage.period
      montly_usage_histories.create(period: montly_usage.period - 1.month,
                                    token_count: current_plan.max_token_count,
                                    extra_token_count: montly_usage.extra_token_count)
    elsif !montly_usage.nil? && today > montly_usage.period + 1.month
      montly_usage_histories.create(period: montly_usage.period + 1.month,
                                    token_count: current_plan.max_token_count,
                                    extra_token_count: montly_usage.extra_token_count)
    elsif !montly_usage.nil? && today >= montly_usage.period && today < montly_usage.period + 1.month
      montly_usage
    end
  end

  def current_plan
    payment_subscriptions.where(status: :active).first&.payment_plan
  end

  def current_subscription
    payment_subscriptions.where(status: :active).first
  end

  def current_plan_canceled?
    payment_subscriptions.where(status: :canceled).exists?
  end

  def cancel_active_subscription
    @payment_subscription = payment_subscriptions.where(status: :active).first

    return unless !@payment_subscription.nil? && @payment_subscription.active

    update(active: false) if @payment_subscriptions.cancel_galax_pay_payment_subscription
  end

  def send_connection_fail_mail
    PartnerMailer._send_connection_fail_mail(self).deliver
    notifications.create(
      title: 'A sua conta precisa de sua atenção!',
      description: 'Parece haver um problema com a sua conexao com o aplicatiovo do Whats App, precisamos que vc conecte novamente ao seu aparelho!',
      notification_type: :connection_fail
    )
  end

  def montly_tokens_consumed
    return unless current_plan

    tokens_plan = current_plan.max_token_count
    return unless tokens_plan

    return unless current_mothly_history

    current_extra_token = extra_tokens.sum(:token_quantity)
    remaining_tokens = (current_mothly_history.token_count + current_extra_token)
    ((current_extra_token + tokens_plan) - remaining_tokens)
  end

  def montly_remaining_tokens
    return unless current_plan

    return unless current_mothly_history

    current_extra_token = extra_tokens.sum(:token_quantity)
    (current_mothly_history.token_count + current_extra_token)
  end

  def connected_with_google
    access_token.present? && refresh_token.present?
  end

  def profile_filled?
    name.present? && email.present? && contact_number.present? && document.present?
  end

  def partner_details_filled?
    !partner_detail.nil? && partner_detail.details_filled?
  end

  def active_plan?
    !current_subscription.nil? && !current_plan.nil? && current_plan.name != 'Plano Gratuito'
  end

  def customer_status
    if active? && current_plan.present?
      'Cliente Ativo'
    elsif current_plan.nil? && profile_filled?
      'Dados Preenchidos'
    elsif current_plan_canceled?
      'Cliente Inativo'
    else
      'Status Desconhecido'
    end
  end
end
