class Api::V1::Admins::PaymentTransactionsController < ApiAdminController
  def index
    start_at = 0
    start_at = (params['page'].to_i - 1) * 10 unless params['page'].nil?
    status = params['status'] unless params['status'].nil?

    trasanctions = GalaxPayClient.get_all_transactions(status, start_at, 10)
    render json: trasanctions
  end

  def by_client
    partner = Partner.find(params[:id])
    start_at = 0
    start_at = (params['page'].to_i - 1) * 10 unless params['page'].nil?
    status = params['status'] unless params['status'].nil?

    trasanctions = partner.list_transactions(status, start_at, 10)
    render json: trasanctions
  end
end
