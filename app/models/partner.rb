class Partner < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable

  attr_accessor :current_password, :auth_token, :expires_at

  extend FriendlyId
  friendly_id :name_slug, use: :slugged

  validates :name, :phone, presence: true
  validates :password_confirmation, presence: true, on: :create

  def name_slug
    return unless name.present?

    ["#{name.parameterize}"]
  end
end
