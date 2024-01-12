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
    @payment = Payment.new(payment_params.merge(partner: @current_partner))
    if @payment.save
      if @payment.status != 'active'
        @current_partner.update(active: false)
        render json: { message: 'Falha em criar inscricao verifique os dados' }, status: :unprocessable_entity
      else
        @current_partner.update(active: true)
        render json: PaymentSerializer.new(@payment).serialized_json, status: :created
      end
    else
      render json: ErrorSerializer.serialize(@payment.errors), status: :unprocessable_entity
    end
  end

  def payment_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:payment])
  end

  def set_payment
    @payment = Payment.find(params[:id])
  end
end