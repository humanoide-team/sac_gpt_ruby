class Api::V1::Affiliates::ProspectCardsController < ApiPartnerController
  before_action :set_prospect_card, only: %i[index show destroy update]

  def index
    @prospect_cards = @current_affiliate.propect_cards
    render json: ProspectCardSerializer.new(@prospect_cards).serialized_json, status: :ok
  end

  def show
    render json: ProspectCardSerializer.new(@prospect_card).serialized_json, status: :ok
  end

  def create
    @prospect_card = ProspectCard.new(prospect_card_params.merge(affiliate: @current_affiliate))

    if @prospect_card.save
      render json: ProspectCardSerializer.new(@prospect_card).serialized_json, status: :created
    else
      render json: ErrorSerializer.serialize(@prospect_card.errors), status: :unprocessable_entity
    end
  end

  def destroy
    if @prospect_card.destroy
      render json: ProspectCardSerializer.new(@prospect_card).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@prospect_card.errors), status: :unprocessable_entity
    end
  end

  def update
    if @prospect_card.update(prospect_card_params)
      render json: ProspectCardSerializer.new(@prospect_card).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@prospect_card.errors), status: :unprocessable_entity
    end
  end

  private

  def prospect_card_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:prospect_card])
  end

  def set_prospect_card
    @prospect_card = ProspectCard.find(params[:id])
  end
end
