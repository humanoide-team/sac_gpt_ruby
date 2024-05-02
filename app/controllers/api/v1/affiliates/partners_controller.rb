class Api::V1::Affiliates::PartnersController < ApiAffiliateController

  def show
    @affiliate = Affiliate.find(params[:id])
    @partners = Partner.where(affiliate_id: @affiliate.id)

    render json: PartnerSerializer.new(@partners).serialized_json
  end
end
