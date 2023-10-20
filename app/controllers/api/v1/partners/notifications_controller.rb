class Api::V1::Partners::NotificationsController < ApiPartnerController
  def index
    @notifications = @current_partner.notifications.where(readed: false)
    render json: NotificationSerializer.new(@notifications).serialized_json, status: :ok
  end

  def update
    if @notification.update(readed: true)
      render json: NotificationSerializer.new(@notification).serialized_json, status: :ok
    else
      render json: ErrorSerializer.serialize(@notification.errors), status: :unprocessable_entity
    end
  end

  private

  def notifications_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, polymorphic: [:notification])
  end

  def set_notification
    @notification = Notification.find(params[:id])
  end
end
