require 'securerandom'

class Partner < ApplicationRecord
  acts_as_paranoid

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable

  attr_accessor :current_password, :auth_token, :expires_at

  extend FriendlyId
  friendly_id :name_slug, use: :slugged

  has_one :partner_detail, dependent: :destroy
  has_many :partner_client_messages, dependent: :destroy
  has_many :partner_clients, through: :partner_client_messages
  has_many :partner_payments, dependent: :destroy
  has_many :credit_cards, dependent: :destroy
  has_many :payment_subscriptions, dependent: :destroy
  has_many :partner_client_leads, dependent: :destroy

  validates :name, :service_number, :document, :contact_number, presence: true
  validates :password_confirmation, presence: true, on: :create

  accepts_nested_attributes_for :partner_detail, reject_if: :all_blank

  after_save :generate_instance_key, unless: :instance_key?
  after_create :send_welcome_mail

  before_create :create_galax_pay_client

  after_update :generate_instance_key, if: :service_number_is_updated?

  def send_welcome_mail
    PartnerMailer._send_welcome_partner(self).deliver
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
    @verifier.generate(data, expires_in: 30.minutes)
  end

  def generate_recover_password_key
    data = encrypted_data(email, ENV['ENCRYPTION_KEY'])
    puts data
    data
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
end