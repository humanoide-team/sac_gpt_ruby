require 'securerandom'

class Partner < ApplicationRecord
  acts_as_paranoid

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable

  attr_accessor :current_password, :auth_token, :expires_at

  extend FriendlyId
  friendly_id :name_slug, use: :slugged

  belongs_to :affiliate, optional: true
  has_one :partner_detail, dependent: :destroy
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
  has_one :schedule_setting, dependent: :destroy
  has_one :conversation_thread_, dependent: :destroy
  has_one :partner_assistent, dependent: :destroy

  validates :name, :document, :contact_number, presence: true, on: :create
  validates :password_confirmation, presence: true, on: :create

  accepts_nested_attributes_for :partner_detail, reject_if: :all_blank

  after_save :generate_instance_key, unless: :instance_key?
  after_create :send_welcome_mail

  before_create :create_galax_pay_client

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
    @verifier.generate(data, expires_in: 365.days)
  end

  def generate_recover_password_key
    encrypted_data(email, ENV['ENCRYPTION_KEY'])
  end

  def generate_instance_key
    token = encrypted_data(id.to_s, generate_key)
    update_attribute(:instance_key, token)
  end

  def create_galax_pay_client
    uuid = SecureRandom.uuid
    galax_pay_client = GalaxPayClient.create_client(uuid, name, document, email, contact_number)

    if galax_pay_client.nil?
      errors.add(:base, 'Erro ao criar Client')
      throw :abort
    else
      self.galax_pay_id = galax_pay_client['galaxPayId'].to_i
      self.galax_pay_my_id = galax_pay_client['myId']
    end
  end

  def list_transactions(status, start_at, limit)
    GalaxPayClient.get_transactions_by_client(galax_pay_id, status, start_at, limit)
  end

  def service_number_is_updated?
    saved_change_to_service_number?
  end

  def current_mothly_history
    date = Date.today

    historie = montly_usage_histories.where(period: date.beginning_of_month..(date.end_of_month + 23.hours)).first
    historie = montly_usage_histories.create(period: Date.today, token_count: 0) if historie.nil?
    historie
  end

  def current_plan
    payment_subscriptions.where(status: :active).first&.payment_plan
  end

  def current_plan_canceled?
    payment_subscriptions.where(status: :canceled).exists?
  end

  def cancel_active_subscription
    @payment_subscription = payment_subscriptions.where(status: :active).first

    self.update(active: false) if @payment_subscriptions.cancel_galax_pay_payment_subscription
  end

  def send_connection_fail_mail
    PartnerMailer._send_connection_fail_mail(self).deliver
    notifications.create(
      title: 'A sua conta precisa de sua atenção!',
      description: 'Parece haver um problema com a sua conexao com o aplicatiovo do Whats App, precisamos que vc conecte novamente ao seu aparelho!',
      notification_type: :connection_fail
    )
  end

  def details_filled?
    name.present? && email.present? && contact_number.present? && document.present?
  end

  def customer_status
    if active? && current_plan.present?
      'Cliente Ativo'
    elsif current_plan.nil? && details_filled?
      'Dados Preenchidos'
    elsif current_plan_canceled?
      'Cliente Inativo'
    else
      'Status Desconhecido'
    end
  end
end
