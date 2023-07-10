class ApiPartnerController < ActionController::Base
  include HTTParty

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  # before_action :set_paper_trail_whodunnit

  before_action :authenticate_request
  attr_reader :current_user

  def user_for_paper_trail
    "Partner: #{current_partner&.id}"
  end

  private

  def authenticate_request
    @current_partner = AuthorizePartnerApiRequest.call(request.headers).result
    render json: { error: 'Not Authorized' }, status: 401 unless @current_partner
  end

  def respond_with_errors(object)
    render json: { errors: ErrorSerializer.serialize(object) }, status: :unprocessable_entity
  end
end
