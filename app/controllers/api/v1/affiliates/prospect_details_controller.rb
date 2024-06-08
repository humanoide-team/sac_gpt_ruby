class Api::V1::Affiliates::ProspectDetailsController < ApiAffiliateController
  before_action :set_prospect_detail, only: %i[show destroy update]

  def show
    render json: ProspectDetailSerializer.new(@prospect_detail).serialized_json, status: :ok
  end

  def create
    @prospect_detail = ProspectDetail.new(prospect_detail_params)

    if @prospect_detail.save
      render json: ProspectDetailSerializer.new(@prospect_detail).serialized_json, status: :created
    else
      render json: ErrorSerializer.serialize(@prospect_detail.errors), status: :unprocessable_entity
    end
  end

  def destroy
    if @prospect_detail.destroy
      render json: ProspectDetailSerializer.new(@prospect_detail).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@prospect_detail.errors), status: :unprocessable_entity
    end
  end

  def update
    if @prospect_detail.update(prospect_detail_params)
      render json: ProspectDetailSerializer.new(@prospect_detail).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@prospect_detail.errors), status: :unprocessable_entity
    end
  end

  private

  def prospect_detail_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:prospect_detail])
  end

  def set_prospect_detail
    @prospect_detail = ProspectDetail.find(params[:id])
  end
end
