class Api::V1::Partners::CreditCardsController < ApiPartnerController
  before_action :set_credit_card, only: %i[show destroy]

  def index
    credit_cards = @current_partner.credit_cards
    render json: CreditCardSerializer.new(credit_cards).serialized_json, status: :ok
  end

  def show
    render json: CreditCardSerializer.new(@credit_card).serialized_json, status: :ok
  end

  def create
    @credit_card = CreditCard.new(credit_card_params.merge(partner: @current_partner))
    if @credit_card.save
      render json: CreditCardSerializer.new(@credit_card).serialized_json, status: :created
    else
      render json: ErrorSerializer.serialize(@credit_card.errors), status: :unprocessable_entity
    end
  end

  def destroy
    if @credit_card.destroy
      render json: CreditCardSerializer.new(@credit_card).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@credit_card.errors), status: :unprocessable_entity
    end
  end

  def credit_card_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:credit_cards])
  end

  def set_credit_card
    @credit_card = CreditCard.find(params[:id])
  end
end