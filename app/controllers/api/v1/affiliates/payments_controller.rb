class Api::V1::Affiliates::PaymentsController < ApiAffiliateController
  before_action :set_payment, only: %i[show]

  def index
    @payments = @current_affiliate.affiliate_payments
    render json: PaymentSerializer.new(@payments).serialized_json
  end

  def show
    render json: PaymentSerializer.new(@payment).serialized_json, status: :ok
  end

  def create
    @payment = AffiliatePayment.new(payment_params.merge(affiliate: @current_affiliate,affiliate_extra_token_attributes: { token_quantity: payment_params[:token_quantity],affiliate: @current_affiliate }).except(:token_quantity))

    if @payment.save
      if @payment.status != 'active'
        render json: { message: 'Falha em criar pagamento verifique os dados' }, status: :unprocessable_entity
      else
        @current_affiliate.update(active: true) if @current_affiliate.active != true
        render json: PaymentSerializer.new(@payment).serialized_json, status: :created
      end
    else
      render json: ErrorSerializer.serialize(@payment.errors), status: :unprocessable_entity
    end
  end

  def payment_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:payment], permit: [:token_quantity])
  end

  def set_payment
    @payment = AffiliatePayment.find(params[:id])
  end
end
