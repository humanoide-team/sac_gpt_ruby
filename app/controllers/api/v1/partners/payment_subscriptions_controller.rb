class Api::V1::Partners::PaymentSubscriptionsController < ApiPartnerController
  before_action :set_payment_subscription, only: %i[show destroy cancel]

  def index
    @payment_subscriptions = @current_partner.payment_subscriptions
    render json: PaymentSubscriptionSerializer.new(@payment_subscriptions).serialized_json
  end

  def show
    render json: PaymentSubscriptionSerializer.new(@payment_subscription).serialized_json, status: :ok
  end

  def last_active_subscription
    @payment_subscription = @current_partner.payment_subscriptions.where.not(status: :canceled).last
    render json: PaymentSubscriptionSerializer.new(@payment_subscription).serialized_json, status: :ok
  end

  def create
    payment_subscriptions = @current_partner.payment_subscriptions.where(status: :active)
    if !payment_subscriptions.empty?
      payment_subscriptions.each do |subs|
        subs.cancel_galax_pay_payment_subscription
      end
    end

    @payment_subscription = PaymentSubscription.new(payment_subscription_params.merge(partner: @current_partner))
    if @payment_subscription.save
      if @payment_subscription.status == 'active'
        @current_partner.update(active: true)
        render json: PaymentSubscriptionSerializer.new(@payment_subscription).serialized_json, status: :created
      elsif @payment_subscription.status == 'waitingPayment'
        @current_partner.update(active: false)
        render json: { message: 'Aguardando Confirmação De Pagamento' }, status: :ok
      else
        @current_partner.update(active: false)
        render json: { message: 'Falha em criar inscricao verifique os dados' }, status: :unprocessable_entity
      end
    else
      render json: ErrorSerializer.serialize(@payment_subscription.errors), status: :unprocessable_entity
    end
  end

  def cancel
    if @payment_subscription.cancel_galax_pay_payment_subscription

      @current_partner.update(active: false)
      render json: PaymentSubscriptionSerializer.new(@payment_subscription).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@payment_subscription.errors), status: :unprocessable_entity
    end
  end

  def destroy
    if @payment_subscription.cancel_galax_pay_payment_subscription
      @current_partner.update(active: false)
      render json: PaymentSubscriptionSerializer.new(@payment_subscription).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@payment_subscription.errors), status: :unprocessable_entity
    end
  end

  def payment_subscription_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:payment_subscription])
  end

  def set_payment_subscription
    @payment_subscription = PaymentSubscription.find(params[:id])
  end
end