class Partner < ApplicationRecord
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

  validates :name, :service_number, :document, :contact_number, presence: true
  validates :password_confirmation, presence: true, on: :create

  accepts_nested_attributes_for :partner_detail, reject_if: :all_blank

  after_save :generate_instance_key, unless: :instance_key?

  after_create :create_galax_pay_client

  def name_slug
    return unless name.present?

    [name.parameterize.to_s]
  end

  def generate_key
    SecureRandom.random_bytes(32)
  end

  def encrypted_data(data)
    crypt = ActiveSupport::MessageEncryptor.new(generate_key)
    crypt.encrypt_and_sign(data)
  end

  def create_galax_pay_client
    galax_pay_id = GalaxPayClient.create_client(id, name, document, email, contact_number)
    update_attribute(:galax_pay_id, galax_pay_id)
  end

  def list_transactions
    transactions = GalaxPayClient.get_transactions_by_client(galax_pay_id)
  end

  def generate_instance_key
    token = encrypted_data(id.to_s)
    update_attribute(:instance_key, token)
  end
end
