class Api::V1::Partners::ScheduleSettings < ApiPartnerController
  before_action :set_schedule_setting, only: %i[show update]

  def show
    render json: ScheduleSettingSerializer.new(@schedule_setting).serialized_json, status: :ok
  end

  def create
    @schedule_setting = @current_partner.schedule_setting.new(schedule_setting_params)

    if @schedule_setting.save
      render json: ScheduleSettingSerializer.new(@schedule_setting).serialized_json, status: :created
    else
      render json: ErrorSerializer.serialize(@schedule_setting.errors), status: :unprocessable_entity
    end
  end

  def update
    if @schedule_setting.update(schedule_setting_params)
      render json: ScheduleSettingSerializer.new(@schedule_setting).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@schedule_setting.errors), status: :unprocessable_entity
    end
  end

  private

  def schedule_setting_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:schedule_setting])
  end

  def set_schedule_setting
    @schedule_setting = ScheduleSetting.find(params[:id])
  end
end
