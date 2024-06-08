class Api::V1::Partners::PartnerReportsController < ApiPartnerController
  def index
    # Overview
    current_extra_token = @current_partner.extra_tokens.sum(:token_quantity)
    partner_leads = @current_partner.partner_client_leads
    montly_usage = @current_partner.current_mothly_history
    lead_count = partner_leads.count
    token_limit = @current_partner.current_plan&.max_token_count || 0
    montly_tokens_left = (token_limit + current_extra_token) - montly_usage.token_count
    client_scores = partner_leads.order(lead_score: :desc).limit(10).map do |pl|
      {
        client: PartnerClientSerializer.new(pl.partner_client),
        clientScore: pl.lead_score
      }
    end

    client_messages = @current_partner.partner_client_messages
                                      .select('DISTINCT ON (partner_client_id) *')
                                      .order('partner_client_id, created_at DESC')
                                      .limit(5)
                                      .map do |pcm|
      {
        client: PartnerClientSerializer.new(pcm.partner_client),
        clientLastMessage: pcm.message,
      }
    end


    # Attendant Performance
    answers_count = @current_partner.partner_client_messages.count

    # JSON
    render json: {
      data: {
        id: @current_partner.id,
        type: 'partner',
        reports: {
          overview: {
            leadCount: lead_count,
            clientScores: client_scores
          },
          attendantPerformance: {
            answersCount: answers_count
          },
          usageStatistics: {
            montlyTokensConsumed: montly_usage.token_count,
            monthlyTokensLeft: montly_tokens_left
          },
          clientMessages: client_messages,
          salesAnalysis: {}
        }
      }
    }, status: :ok
  end
end
