class AuthorizePartnerApiRequest
  prepend SimpleCommand

  def initialize(headers = {}, options = {})
    @headers = headers
  end

  def call
    partner
  end

  private

  attr_reader :headers

  def partner
    @partner ||= Partner.find_by_id(decoded_auth_token[:partner_id]) if decoded_auth_token
    @partner || errors.add(:token, 'Invalid token') && nil
  end

  def decoded_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(http_auth_header)
  end

  def http_auth_header
    if headers['Authorization'].present?
      return headers['Authorization'].split(' ').last
    else
      errors.add(:token, 'Missing token')
    end
    nil
  end
end
