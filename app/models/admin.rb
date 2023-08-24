class Admin < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  attr_accessor :current_password, :auth_token, :expires_at

  extend FriendlyId
  friendly_id :name_slug, use: :slugged

  validates :name, presence: true
  validates :password_confirmation, presence: true, on: :create

  def name_slug
    return unless name.present?

    ["#{name.parameterize}"]
  end

  def weekly_summary_mail
    AdminMailer._send_weekly_summary(self).deliver
  end

  def recovery_password_mail
    AdminMailer._send_recovery_password(self).deliver
  end
end
