class Api::V1::Admins::PaymentPlansController < ApiAdminController
  before_action :set_payment_plan, only: %i[show destroy update]

  def index
    @payment_plans = PaymentPlan.all.order(id: :asc)
    render json: PaymentPlanSerializer.new(@payment_plans).serialized_json
  end

  def show
    render json: PaymentPlanSerializer.new(@payment_plan).serialized_json
  end

  def create
    @payment_plan = PaymentPlan.new(payment_plan_params)

    if @payment_plan.save
      render json: PaymentPlanSerializer.new(@payment_plan).serialized_json, status: :created
    else
      render json: ErrorSerializer.serialize(@payment_plan.errors), status: :unprocessable_entity
    end
  end

  def destroy
    if @payment_plan.destroy
      render json: PaymentPlanSerializer.new(@payment_plan).serialized_json, status: :created
    else
      render json: ErrorSerializer.serialize(@payment_plan.errors), status: :unprocessable_entity
    end
  end

  private

  def payment_plan_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:payment_plan])
  end

  def set_payment_plan
    @payment_plan = PaymentPlan.find(params[:id])
  end
end
