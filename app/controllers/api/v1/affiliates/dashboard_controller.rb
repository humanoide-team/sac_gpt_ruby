class Api::V1::Affiliates::DashboardController < ApiAffiliateController
  def index
    closing_date = DateTime.now
    closing_start = closing_date.beginning_of_month
    closing_end = closing_date.end_of_month

    financial_date = (DateTime.now - 2.months)
    financial_start = financial_date.beginning_of_month
    financial_end = financial_date.end_of_month

    closing = @current_affiliate.revenues.where(created_at: closing_start..closing_end).sum(:value)
    financial = @current_affiliate.revenues.where(created_at: financial_start..financial_end).sum(:value)

    news_propect = @current_affiliate.prospect_cards.where(status: 'prospec').count
    closed_propect = @current_affiliate.prospect_cards.where(status: 'closure').count
    all_propect = @current_affiliate.prospect_cards.count
    propect_success = @current_affiliate.prospect_cards.select { |pc| pc.partner_linked }.count

    montly_usage = @current_affiliate.current_mothly_history

    token_count = @current_affiliate&.bot_configuration&.token_count || 0
    render json: {
      data: {
        id: @current_affiliate.id,
        type: 'dashboard',
        montly_usage: {
          remaining_token: montly_usage.token_count,
          plan_tokens: @current_affiliate.max_token_count,
          extra_tokens: montly_usage.extra_token_count
        },
        testBot: {
          spentTokens: token_count,
          closed: closed_propect
        },
        salesFunnel: {
          new: news_propect,
          closed: closed_propect,
          all: all_propect,
          becamePartner: propect_success
        },
        salesAnalysis: {
          closing:,
          financial:
        }
      }
    }, status: :ok
  end
end
