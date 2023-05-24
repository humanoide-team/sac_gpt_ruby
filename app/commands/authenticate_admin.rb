require 'json_web_token.rb'

class AuthenticateAdmin
  prepend SimpleCommand
  attr_accessor :current_admin

  def initialize(options = {})
    @email = options[:email] || ''
    @password = options[:password] || ''
    @expires_at = options[:expires_at]&.to_i || 30.days.from_now.to_i
    @current_admin = nil
  end

  def call
    JsonWebToken.encode({admin_id: admin.id, exp: @expires_at, model_name: 'Manager'}) if admin
  end

  private

  attr_accessor :email, :password

  def admin
    admin = Admin.find_by(email: email)
    if admin&.valid_password?(password) && !admin&.created_at.nil?
      @current_admin = admin
      return @current_admin
    end

    errors.add :admin_authentication, 'invalid credentials'
    nil
  end
end
