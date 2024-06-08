class Api::V1::Affiliates::AffiliateBankDetailsController < ApiAffiliateController
  before_action :set_bank_detail, only: %i[show update]

  def show
    render json: AffiliateBankDetailsSerializer.new(@affiliate_bank_detail).serialized_json
  end

  def create
    @bank_detail = @current_affiliate.build_affiliate_bank_detail(bank_detail_params)

    if @bank_detail.save
      render json: AffiliateBankDetailsSerializer.new(@bank_detail).serialized_json, status: :created
    else
      render json: { errors: @bank_detail.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @affiliate_bank_detail.update(bank_detail_params)
      render json: AffiliateBankDetailsSerializer.new(@affiliate_bank_detail).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@affiliate_bank_detail.errors), status: :unprocessable_entity
    end
  end

  private

  def bank_detail_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:affiliate_bank_detail])
  end

  def set_bank_detail
    @affiliate_bank_detail = @current_affiliate.affiliate_bank_detail
  end
end
