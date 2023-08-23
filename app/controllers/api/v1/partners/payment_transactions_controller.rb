class Api::V1::Partners::PaymentTransactionsController < ApiPartnerController
  def index
    start_at = 0
    start_at = (params['page'].to_i - 1) * 100 unless params['page'].nil?

    trasanctions = @current_partner.list_transactions(start_at, 100)
    render json: trasanctions
  end
end