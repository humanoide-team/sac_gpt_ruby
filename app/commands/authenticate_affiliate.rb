require 'json_web_token.rb'

class AuthenticateAffiliate
  prepend SimpleCommand
  attr_accessor :current_affiliate

  def initialize(options = {})
    @email = options[:email] || ''
    @password = options[:password] || ''
    @expires_at = options[:expires_at]&.to_i || 30.days.from_now.to_i
    @current_affiliate = nil
  end

  def call
    JsonWebToken.encode({affiliate_id: affiliate.id, exp: @expires_at, model_name: 'Affiliate'}) if affiliate
  end

  private

  attr_accessor :email, :password

  def affiliate
    affiliate = Affiliate.find_by(email: email)
    if affiliate&.valid_password?(password) && !affiliate&.created_at.nil?
      @current_affiliate = affiliate
      return @current_affiliate
    end

    errors.add :affiliate_authentication, 'invalid credentials'
    nil
  end
end
