class Api::V1::Partners::AuthenticationController < ApiPartnerController
  skip_before_action :authenticate_request

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
end
