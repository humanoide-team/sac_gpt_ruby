class Api::V1::Partners::PartnerClientsController < ApiPartnerController
  before_action :set_client, only: %i[destroy]

  def index
    @clients = @current_partner.partner_clients.order(id: :asc).uniq
    render json: PartnerClientSerializer.new(@clients).serialized_json, status: :ok
  end

  def destroy
    if @client.destroy
      render json: PartnerClientSerializer.new(@client).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@client.errors), status: :unprocessable_entity
    end
  end

  private

  def set_client
    @client = @current_partner.partner_clients.find(params[:id])
  end
end
