class Api::V1::Affiliates::RevenuesController < ApiAffiliateController
  def index
    closing_date = DateTime.now
    closing_start = closing_date.beginning_of_month
    closing_end = closing_date.end_of_month

    financial_date = (DateTime.now - 2.months)
    financial_start = financial_date.beginning_of_month
    financial_end = financial_date.end_of_month

    revenues = @current_affiliate.revenues
    closing = @current_affiliate.revenues.where(created_at: closing_start..closing_end).sum(:value)
    financial = @current_affiliate.revenues.where(created_at: financial_start..financial_end).sum(:value)

    render json: {
      data: {
        id: @current_affiliate.id,
        type: 'revenues',
        salesAnalysis: {
          revenues:,
          closing:,
          financial:
        }
      }
    }, status: :ok
  end
end
