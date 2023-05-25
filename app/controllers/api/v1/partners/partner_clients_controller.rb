class Api::V1::Partners::PartnerClientsController < ApiPartnerController
  def index
    @clients = @current_partner.partner_clients.uniq
    render json: PartnerClientSerializer.new(@clients).serialized_json, status: :created
  end
end
