class Api::V1::Partners::PartnersController < ApiPartnerController
  before_action :set_partner, only: %i[show destroy update]
  skip_before_action :authenticate_request, only: %i[create]

  def show
    render json: PartnerSerializer.new(@partner).serialized_json
  end

  def create
    @partner = Partner.new(partner_params)
    @partner.affiliate_id = params[:affiliate_id] if params[:affiliate_id].present?


    if @partner.save
      options = {
        email: partner_params[:email],
        password: partner_params[:password],
        expires_at: 7.days.from_now
      }

      command = AuthenticatePartner.call(options)

      if command.success?
        partner = command.current_partner
        partner.auth_token = command.result
        partner.expires_at = options[:expires_at]
      end

      render json: PartnerSerializer.new(partner).serialized_json, status: :created
    else
      render json: ErrorSerializer.serialize(@partner.errors), status: :unprocessable_entity
    end
  end

  def destroy
    if @partner.destroy
      render json: PartnerSerializer.new(@partner).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@partner.errors), status: :unprocessable_entity
    end
  end

  def update
    if @partner.update(partner_params)
      render json: PartnerSerializer.new(@partner).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@partner.errors), status: :unprocessable_entity
    end
  end

  def calendar_token_auth
    if @partner.update(calendar_token: partner_params[:calendar_token])
      render json: { message: 'Conta conectada' }, status: 200
    else
      render json: { error: 'Usuário não existe' }, status: 401
    end
  end

  private

  def partner_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:partner])
  end

  def set_partner
    @partner = @current_partner
  end
end
