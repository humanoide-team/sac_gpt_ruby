class Api::V1::Affiliates::AffiliateClientMessagesController < ApiAffiliateController

    def index
      @messages = @current_affiliate.affiliate_client_messages.order(id: :asc)
      render json: AffiliateClientMessageSerializer.new(@messages).serialized_json, status: :ok
    end

    def list_by_client
      @messages = @current_affiliate.affiliate_client_messages.where(affiliate_client_id: params[:client_id]).order(id: :asc)
      render json: AffiliateClientMessageSerializer.new(@messages).serialized_json, status: :ok
    end
end