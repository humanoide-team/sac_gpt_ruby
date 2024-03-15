class Api::V1::Partners::MontlyUsageHistoryController < ApiPartnerController
  def index
    day = DateTime.now.day
    tokens_plan = @current_partner.current_plan&.max_token_count

    if tokens_plan.nil?
      return render json: { errors: 'Partner nao tem assinatura de plano' },
                    status: :unprocessable_entity
    end
    current_extra_token = @current_partner.extra_tokens.sum(:token_quantity)
    montly_tokens_consumed = @current_partner.current_mothly_history.token_count + current_extra_token
    average_spent_per_day = montly_tokens_consumed / day
    remaining_tokens = tokens_plan - montly_tokens_consumed
    month_days = DateTime.now.end_of_month.day
    month_clients = @current_partner.partner_clients.where(created_at: DateTime.now.beginning_of_month...DateTime.now.end_of_month).count
    render json: {
      data: {
        id: @current_partner.id,
        type: 'partner',
        usageStatistics: {
          montlyTokensConsumed: montly_tokens_consumed,
          remainingTokens: remaining_tokens,
          averageSpentPerDay: average_spent_per_day,
          totalMonthlySpendingForecast: average_spent_per_day * month_days,
          tokensSpentPerConversation: month_clients.zero? ? 0 : montly_tokens_consumed / month_clients 
        }
      }
    }, status: :ok
  end
end
