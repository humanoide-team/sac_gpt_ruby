require 'tiktoken_ruby'

class Api::V1::WebhooksController < ApiController
  def whatsapp
    @partner = Partner.find_by(instance_key: params['instanceKey'])

    @affiliate = Affiliate.find_by(instance_key: params['instanceKey'])

    if !@partner.nil?
      puts '********************RESPONDENDO****************************'
      PartnerMessageService.process_message(params, @partner)
    elsif !@affiliate.nil?
      puts '********************RESPONDENDO****************************'
      AffiliateMessageService.process_message(params, @affiliate)
    else
      permitted_params = params.permit!
      puts permitted_params
      NodeApiClient.send_callback(permitted_params.to_h)
      puts '***************ENVIOU CALLBACK************************'
    end

    render json: { status: 'OK', current_date: DateTime.now.to_s, params: }
  end
end
