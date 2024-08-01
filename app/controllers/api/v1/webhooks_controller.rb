class Api::V1::WebhooksController < ApiController
  def whatsapp
    response = 'Callback Recebido'
    @partner = Partner.find_by(instance_key: params['session'])
    @affiliate = Affiliate.find_by(instance_key: params['session'])

    payload = params['payload']

    if !@partner.nil?
      puts '********************RESPONDENDO****************************'
      if process_session(params, @partner) == 'MESSAGE'
        response = PartnerMessageService.process_message(payload, @partner)
      end
    elsif !@affiliate.nil?
      puts '********************RESPONDENDO****************************'
      if process_session(params, @affiliate) == 'MESSAGE'
        response = AffiliateMessageService.process_message(payload, @affiliate)
      end
    elsif ENV['WPP_API_SEND_CALLBACK'] == 'true'
      permitted_params = params.permit!
      puts permitted_params
      WahaWppApiClient.send_callback(permitted_params.to_h)
      puts '***************ENVIOU CALLBACK************************'
    end

    render json: { message: response }, status: :ok
  end

  def process_session(params, user)
    return 'MESSAGE' if params['event'] == 'message'

    return 'STATE CHANGE' if params['event'] == 'state.change'

    if params['payload']['status'] == 'STARTING' || params['payload']['status'] == 'SCAN_QR_CODE'
      user.update(last_callback_receive: DateTime.now)
      puts "SESSION #{params['payload']['status']}"
    elsif params['payload']['status'] == 'WORKING'
      user.update(last_callback_receive: DateTime.now, wpp_connected: true)
      puts 'SESSION WORKING'
    elsif params['payload']['status'] == 'FAILED' && user.wpp_connected
      user.update(last_callback_receive: DateTime.now, wpp_connected: false)
      user.send_connection_fail_mail
      puts 'SESSION DISCONECTED'
    end
  end
end
