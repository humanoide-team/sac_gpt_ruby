class Affiliate < ApplicationRecord
  has_many :prospect_cards, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable

  attr_accessor :current_password, :auth_token, :expires_at

  extend FriendlyId
  friendly_id :name_slug, use: :slugged

  validates :name, :document, :contact_number, presence: true, on: :create
  validates :password_confirmation, presence: true, on: :create

  after_save :generate_instance_key, unless: :instance_key?
  after_create :send_welcome_mail

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
end
