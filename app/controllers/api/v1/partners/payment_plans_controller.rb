class Api::V1::Partners::PaymentPlansController < ApiPartnerController
  before_action :set_payment_plan, only: %i[show destroy update]

  def index
    @payment_plans = PaymentPlan.all.order(id: :asc)
    render json: PaymentPlanSerializer.new(@payment_plans).serialized_json
  end

  def show
    render json: PaymentPlanSerializer.new(@payment_plan).serialized_json
  end

  private

  def payment_plan_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:payment_plan])
  end

  def set_payment_plan
    @payment_plan = PaymentPlan.find(params[:id])
  end
end
