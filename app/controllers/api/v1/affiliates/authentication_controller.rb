require 'node_api_client'

class Api::V1::Affiliates::AuthenticationController < ApiAffiliateController
  skip_before_action :authenticate_request, only: %i[authenticate send_recover_password_mail recover_password]

  include HTTParty

  def authenticate
    options = {
      email: params[:email],
      password: params[:password],
      expires_at: 7.days.from_now
    }
    command = AuthenticateAffiliate.call(options)

    if command.success?
      affiliate = command.current_affiliate
      affiliate.auth_token = command.result
      affiliate.expires_at = options[:expires_at]

      render json: AffiliateSerializer.new(affiliate).serialized_json
    else
      render json: { error: command.errors }, status: :unauthorized
    end
  end

  def auth_whatsapp
    instance_key = @current_affiliate.instance_key
    @current_affiliate.update(last_callback_receive: nil, wpp_connected: false)

    response = WahaWppApiClient.start_session(instance_key)
    if response
      sleep(10)
      get_qrcode(instance_key)
    else
      render json: { error: 'Erro ao iniciar sessão' }, status: :unprocessable_entity
    end
  end

  def get_qrcode(instance_key)
    qr_code = WahaWppApiClient.obter_qr(instance_key)
    send_data qr_code, type: 'image/png', disposition: 'inline'
  end

  def send_recover_password_mail
    @affiliate = Affiliate.find_by(email: affiliate_params[:email])
    if @affiliate
      @affiliate.password_recovery_mail
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
    @affiliate = Affiliate.find_by(email: mail)
    if @affiliate
      @affiliate.update(affiliate_params)
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

  def affiliate_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:affiliate])
  end

  def decrypted_data(data, key)
    @verifier = ActiveSupport::MessageVerifier.new(key)
    @verifier.verify(data)
  end

  def current_affiliate
    @current_affiliate ||= current_user
  end
end
