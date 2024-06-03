class Api::V1::Affiliates::AffiliateClientMessagesController < ApiAffiliateController
  def index
    @messages = @current_affiliate.affiliate_client_messages.order(id: :asc)
    render json: AffiliateClientMessageSerializer.new(@messages).serialized_json, status: :ok
  end

  def list_by_client
    @messages = @current_affiliate.affiliate_client_messages.where(affiliate_client_id: params[:client_id]).order(id: :asc)
    render json: AffiliateClientMessageSerializer.new(@messages).serialized_json, status: :ok
  end

  def last_client_messages
    last_client = @current_affiliate.affiliate_clients.sort_by do |ac|
      last_message = ac.affiliate_client_messages.by_affiliate(@current_affiliate).last
      last_message ? last_message.created_at : Time.at(0)
    end.reverse.uniq.first

    return render json: { error: 'No client found' }, status: :not_found if last_client.nil?

    @messages = @current_affiliate.affiliate_client_messages.where(affiliate_client_id: last_client.id).order(id: :asc)
    render json: AffiliateClientMessageSerializer.new(@messages).serialized_json, status: :ok
  end
end
