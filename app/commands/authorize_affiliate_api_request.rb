class AuthorizeAffiliateApiRequest
  prepend SimpleCommand

  def initialize(headers = {}, options = {})
    @headers = headers
  end

  def call
    affiliate
  end

  private

  attr_reader :headers

  def affiliate
    @affiliate ||= Affiliate.find_by_id(decoded_auth_token[:affiliate_id]) if decoded_auth_token
    @affiliate || errors.add(:token, 'Invalid token') && nil
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
