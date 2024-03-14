class Api::V1::Partners::MontlyUsageHistoryController < ApiPartnerController
  def index
    day = DateTime.now.day
    montly_tokens_consumed = @current_partner.current_mothly_history.token_count
    tokens_plan = @current_partner.payment_plan.max_token_count
    average_spent_per_day = montlyTokensConsumed / day
    remaining_tokens = tokens_plan - montlyTokensConsumed
    month_days = DateTime.now.end_of_month.day
    month_clients = @current_partner.partner_clients.where(created_at: DateTime.now.beginning_of_month...DateTime.now.end_of_month)
    render json: {
      data: {
        id: @current_partner.id,
        type: 'partner',
        usageStatistics: {
          montlyTokensConsumed: montly_tokens_consumed,
          remainingTokens: remaining_tokens,
          averageSpentPerDay: average_spent_per_day,
          totalMonthlySpendingForecast: averageSpentPerDay * month_days,
          tokensSpentPerConversation: montlyTokensConsumed / month_clients
        }
      }
    }, status: :ok
  end
end
