class Api::V1::Affiliates::CreditCardsController < ApiAffiliateController
  before_action :set_affiliate_credit_card, only: %i[show destroy]

  def index
    affiliate_credit_cards = @current_affiliate.affiliate_credit_cards
    render json: CreditCardSerializer.new(affiliate_credit_cards).serialized_json, status: :ok
  end

  def show
    render json: CreditCardSerializer.new(@credit_card).serialized_json, status: :ok
  end

  def create
    @credit_card = AffiliateCreditCard.new(credit_card_params.merge(affiliate: @current_affiliate))
    if @credit_card.save
      render json: CreditCardSerializer.new(@credit_card).serialized_json, status: :created
    else
      render json: ErrorSerializer.serialize(@credit_card.errors), status: :unprocessable_entity
    end
  end

  def destroy
    unless @credit_card.payment_subscription.nil?
      return render json: { error: 'Cartão de credito associado a uma assinatura não pode ser excluido' },
                    status: :unprocessable_entity
    end

    if @credit_card.destroy
      render json: CreditCardSerializer.new(@credit_card).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@credit_card.errors), status: :unprocessable_entity
    end
  end

  def credit_card_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:affiliate_credit_cards])
  end

  def set_affiliate_credit_card
    @credit_card = AffiliateCreditCard.find(params[:id])
  end
end
