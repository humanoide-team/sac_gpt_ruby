require 'json_web_token.rb'

class AuthenticatePartner
  prepend SimpleCommand
  attr_accessor :current_partner

  def initialize(options = {})
    @email = options[:email] || ''
    @password = options[:password] || ''
    @expires_at = options[:expires_at]&.to_i || 30.days.from_now.to_i
    @current_partner = nil
  end

  def call
    JsonWebToken.encode({partner_id: partner.id, exp: @expires_at, model_name: 'Partner'}) if partner
  end

  private

  attr_accessor :email, :password

  def partner
    partner = Partner.find_by(email: email)
    if partner&.valid_password?(password) && !partner&.created_at.nil?
      @current_partner = partner
      return @current_partner
    end

    errors.add :partner_authentication, 'invalid credentials'
    nil
  end
end
