class Api::V1::Partners::PartnersController < ApiPartnerController
  before_action :set_partner, only: %i[show destroy update]
  skip_before_action :authenticate_request, only: %i[create]

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

  private

  def partner_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:partner])
  end

  def set_partner
    @partner = Partner.find(params[:id])
  end
end
