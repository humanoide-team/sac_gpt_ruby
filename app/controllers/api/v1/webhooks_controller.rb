class Api::V1::WebhooksController < ApiController
  def whatsapp
    render json: { status: "OK", current_date: DateTime.now.to_s, params: params }
  end
end
