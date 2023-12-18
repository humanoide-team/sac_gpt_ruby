class Api::V1::Partners::SupportController < ApiPartnerController
  def send_mail
    PartnerMailer._send_support_mail(support_params[:contact], support_params[:subject], support_params[:body]).deliver
    render json: { message: 'E-mail enviado!' }, status: :ok
  end

  def support_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params)
  end
end
