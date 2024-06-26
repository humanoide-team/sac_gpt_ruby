require 'node_api_client'

class Api::V1::Partners::AuthenticationController < ApiPartnerController
  skip_before_action :authenticate_request, only: %i[authenticate send_recover_password_mail recover_password]

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

    response = NodeApiClient.iniciar_instancia(token, key)
    if response['error'] == false
      key = response['key']
      sleep(5)
      get_qrcode(key)
      @current_partner.update(wpp_connected: true)
    else
      response['message']
    end
  end

  def get_qrcode(key)
    qr_code = NodeApiClient.obter_qr(key)
    render json: qr_code
  end

  def send_recover_password_mail
    @partner = Partner.find_by(email: partner_params[:email])
    if @partner
      @partner.password_recovery_mail
      render json: {
        data: {
          attributes: {
            message: 'Email de recupecao de senha enviado!'
          }
        }
      }, status: :ok
    else
      render json: {
        'errors': [
          {
            'status': '404',
            'title': 'Not Found'
          }
        ]
      }, status: 404
    end
  end

  def recover_password
    mail = decrypted_data(params[:id], ENV['ENCRYPTION_KEY'])
    @partner = Partner.find_by(email: mail)
    if @partner
      @partner.update(partner_params)
      render json: {
        data: {
          attributes: {
            message: 'Senha atualizada!'
          }
        }
      }, status: :ok
    else
      render json: {
        'errors': [
          {
            'status': '404',
            'title': 'Not Found'
          }
        ]
      }, status: 404
    end
  end

  private

  def partner_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:partner])
  end

  def decrypted_data(data, key)
    @verifier = ActiveSupport::MessageVerifier.new(key)
    @verifier.verify(data)
  end

  def current_partner
    @current_partner ||= current_user
  end
end
