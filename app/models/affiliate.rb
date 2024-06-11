class Affiliate < ApplicationRecord
  acts_as_paranoid

  has_many :partners, dependent: :nullify
  has_many :prospect_cards, dependent: :destroy
  has_many :affiliate_client_leads, dependent: :destroy
  has_many :affiliate_client_messages, dependent: :destroy
  has_many :affiliate_clients, dependent: :destroy
  has_many :revenues, dependent: :destroy
  has_many :affiliate_payments, dependent: :destroy
  has_many :affiliate_credit_cards, dependent: :destroy

  has_one :affiliate_bank_detail, dependent: :destroy
  has_one :bot_configuration, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable

  attr_accessor :current_password, :auth_token, :expires_at

  extend FriendlyId
  friendly_id :name_slug, use: :slugged

  validates :name, :document, :contact_number, presence: true, on: :create
  validates :password_confirmation, presence: true, on: :create

  before_create :create_galax_pay_client
  after_create :send_welcome_mail
  after_save :generate_instance_key, unless: :instance_key?
  after_update :generate_instance_key, if: :service_number_is_updated?

  def send_welcome_mail
    AffiliateMailer._send_welcome_affiliate(self).deliver
  end

  def password_recovery_mail
    AffiliateMailer._send_password_recovery_mail(self, generate_recover_password_key).deliver
  end

  def service_number_is_updated?
    saved_change_to_service_number?
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

  def generate_unique_url
    host = ENV['WEB_PAGE']
    affiliate_id = id
    "#{host}cadastro/?affiliate_id=#{affiliate_id}"
  end

  def list_transactions(status, start_at, limit)
    galax_pay_ids = partners.map { |partner| partner.galax_pay_id }.compact.join(', ')

    GalaxPayClient.get_transactions_by_client(galax_pay_ids, status, start_at, limit)
  end

  def last_client
    affiliate_clients.sort_by do |ac|
      last_message = ac.affiliate_client_messages.by_affiliate(self).last
      last_message ? last_message.created_at : Time.at(0)
    end.reverse.uniq.first
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
end
