class Api::V1::Partners::PaymentTransactionsController < ApiPartnerController
  def index
    start_at = 0
    start_at = (params['page'].to_i - 1) * 10 unless params['page'].nil?
    status = params['status'] unless params['status'].nil?

    trasanctions = @current_partner.list_transactions(status, start_at, 10)
    render json: trasanctions
  end
end