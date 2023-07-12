require_relative '../../../../services/node_api_client'

class Api::V1::Partners::AuthenticationController < ApiPartnerController
  skip_before_action :authenticate_request, only: :authenticate
  include HTTParty

  def authenticate
    options = {
      email: params[:email],
      password: params[:password],
      expires_at: 7.days.from_now
    }
    command = AuthenticatePartner.call(options)

    if command.success?
      partner = command.current_partner
      partner.auth_token = command.result
      partner.expires_at = options[:expires_at]

      render json: PartnerSerializer.new(partner).serialized_json
    else
      render json: { error: command.errors }, status: :unauthorized
    end
  end

  def auth_whatsapp
    token = ENV['NODE_API_WHATSAPP_TOKEN']
    key = @current_partner.instance_key

    response = NodeAPIClient.iniciar_instancia(token, key)
    if response['error'] == false
      key = response['key']
      sleep(5)
      get_qrcode(key)
    else
      error_message = response['message']
    end
  end

  def get_qrcode(key)
    qr_code = NodeAPIClient.obter_qr(key)
    render json: qr_code
  end

  private

  def current_partner
    @current_partner ||= current_user
  end
end
