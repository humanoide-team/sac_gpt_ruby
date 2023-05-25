class Api::V1::Partners::PartnerClientMessagesController < ApiPartnerController

  def index
    @messages = @current_partner.partner_client_messages
    render json: PartnerClientMessageSerializer.new(@messages).serialized_json, status: :created
  end

end
