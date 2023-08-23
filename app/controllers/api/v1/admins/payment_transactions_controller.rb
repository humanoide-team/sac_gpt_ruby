class Api::V1::Admins::PaymentTransactionsController < ApiAdminController
  def index
    start_at = 0
    start_at = (params['page'].to_i - 1) * 100 unless params['page'].nil?

    trasanctions = GalaxPayClient.get_all_transactions(start_at, 100)
    render json: trasanctions
  end

  def by_client
    partner = Partner.find(params[:id])
    start_at = 0
    start_at = (params['page'].to_i - 1) * 100 unless params['page'].nil?

    trasanctions = partner.list_transactions(start_at, 100)
    render json: trasanctions
  end
end
