class Api::V1::Affiliates::PartnersController < ApiAffiliateController
  def index
    @partners = @current_affiliate.partners
    render json: PartnerSerializer.new(@partners).serialized_json
  end
end
