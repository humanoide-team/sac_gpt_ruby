class Partner < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable

  attr_accessor :current_password, :auth_token, :expires_at

  extend FriendlyId
  friendly_id :name_slug, use: :slugged

  has_one :partner_detail, dependent: :destroy

  validates :name, :phone, presence: true
  validates :password_confirmation, presence: true, on: :create

  accepts_nested_attributes_for :partner_detail, reject_if: :all_blank

  def name_slug
    return unless name.present?

    ["#{name.parameterize}"]
  end
end
