class Partner < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable

  attr_accessor :current_password, :auth_token, :expires_at

  extend FriendlyId
  friendly_id :name_slug, use: :slugged

  has_one :partner_detail, dependent: :destroy
  has_many :partner_client_messages, dependent: :destroy
  has_many :partner_clients, through: :partner_client_messages

  validates :name, :phone, presence: true
  validates :password_confirmation, presence: true, on: :create

  accepts_nested_attributes_for :partner_detail, reject_if: :all_blank

  after_save :generate_instance_key, unless: :instance_key?

  def name_slug
    return unless name.present?

    ["#{name.parameterize}"]
  end

  def generate_key
    SecureRandom.random_bytes(32)
  end

  def encrypted_data(data)
    crypt = ActiveSupport::MessageEncryptor.new(generate_key)
    crypt.encrypt_and_sign(data)
  end

  def generate_instance_key
    token = encrypted_data(self.id.to_s)
    self.update_attribute(:instance_key, token)
  end

end
