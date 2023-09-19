class Api::V1::Partners::PartnersController < ApiPartnerController
  before_action :set_partner, only: %i[show destroy update]
  skip_before_action :authenticate_request, only: %i[create]

  def authenticate_request(respond_401 = true)
    @current_partner = AuthorizePartnerApiRequest.call(request.headers).result
    render json: { error: 'Not Authorized' }, status: 401 if respond_401 && (!@current_partner || @current_partner.class.name != 'Partner')
  end

  def show
    render json: PartnerAdminSerializer.new(@partner).serialized_json
  end

  def create
    @partner = Partner.new(partner_params)
    
    if @partner.save
      render json: PartnerSerializer.new(@partner).serialized_json, status: :created
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

  def update_password
    options = { email: @current_partner.email, password: partner_params[:password] }
    command = AuthenticatePartner.call(options)
    if command.success?
      if @current_partner.update(password: partner_params[:new_password])
        render json: PartnerSerializer.new(@current_partner).serialized_json
      else
        render json: ErrorSerializer.serialize(@current_partner.errors), status: :unprocessable_entity
      end
    else
      render json: { error: command.errors }, status: :unauthorized
    end
  end

  private

  def partner_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:partner])
  end

  def set_partner
    @partner = Partner.find(params[:id])
  end
end
