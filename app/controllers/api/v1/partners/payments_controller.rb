class Api::V1::Partners::PaymentsController < ApiPartnerController
  before_action :set_payment, only: %i[show]

  def index
    @payments = @current_partner.payments
    render json: PaymentSerializer.new(@payments).serialized_json
  end

  def show
    render json: PaymentSerializer.new(@payment).serialized_json, status: :ok
  end

  def create
    @payment = Payment.new(payment_params.merge(partner: @current_partner,
                                                extra_token_attributes: { token_quantity: payment_params[:token_quantity],
                                                                          partner: @current_partner }).except(:token_quantity))

    if @payment.save
      if @payment.status == 'active' || @payment.status == 'closed'
        @current_partner.update(active: true) if @current_partner.active != true
        render json: PaymentSerializer.new(@payment).serialized_json, status: :created
      elsif @payment.status == 'waitingPayment'
        @current_partner.update(active: false)
        render json: { message: 'Aguardando Confirmação De Pagamento' }, status: :ok
      else
        render json: { message: 'Falha em criar pagamento verifique os dados' }, status: :unprocessable_entity
      end
    else
      render json: ErrorSerializer.serialize(@payment.errors), status: :unprocessable_entity
    end
  end

  def payment_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:payment], permit: [:token_quantity])
  end

  def set_payment
    @payment = Payment.find(params[:id])
  end
end
