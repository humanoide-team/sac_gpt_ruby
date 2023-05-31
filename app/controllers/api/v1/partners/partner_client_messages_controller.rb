class Api::V1::Partners::PartnerClientMessagesController < ApiPartnerController

  def index
    @messages = @current_partner.partner_client_messages.order(id: :asc)
    render json: PartnerClientMessageSerializer.new(@messages).serialized_json, status: :ok
  end

  def list_by_client
    @messages = @current_partner.partner_client_messages.where(partner_client_id: params[:client_id]).order(id: :asc)
    render json: PartnerClientMessageSerializer.new(@messages).serialized_json, status: :ok
  end
  
end
