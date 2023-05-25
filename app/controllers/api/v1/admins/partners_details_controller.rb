class Api::V1::Admins::PartnerDetailsController < ApiAdminController
  before_action :set_partner_detail, only: %i[show destroy update]

  def create
    @partner_detail = PartnerDetail.new(partner_detail_params)

    if @partner_detail.save
      render json: PartnerDetailSerializer.new(@partner_detail).serialized_json, status: :created
    else
      render json: ErrorSerializer.serialize(@partner_detail.errors), status: :unprocessable_entity
    end
  end

  def destroy
    if @partner_detail.destroy
      render json: PartnerDetailSerializer.new(@partner_detail).serialized_json, status: :created
    else
      render json: ErrorSerializer.serialize(@partner_detail.errors), status: :unprocessable_entity
    end
  end

  def update
    if @partner_detail.update(partner_detail_params)
      render json: PartnerDetailSerializer.new(@partner_detail).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@partner_detail.errors), status: :unprocessable_entity
    end
  end

  private

  def partner_detail_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:partner_detail])
  end

  def set_partner_detail
    @partner_detail = PartnerDetail.find(params[:id])
  end
end
