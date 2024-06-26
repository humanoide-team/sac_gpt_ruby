class Api::V1::Partners::PartnerReportsController < ApiPartnerController
  def index
    # Overview
    current_extra_token = @current_partner.current_mothly_history.extra_token_count
    current_token_count = @current_partner.current_mothly_history.token_count
    partner_leads = @current_partner.partner_client_leads
    lead_count = partner_leads.count
    tokens_plan = @current_partner.current_plan&.max_token_count
    montly_tokens_consumed = tokens_plan - token_count
    montly_tokens_left = current_token_count + current_extra_token
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
        clientLastMessage: pcm.message
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
            montlyTokensConsumed: montly_tokens_consumed,
            monthlyTokensLeft: montly_tokens_left
          },
          clientMessages: client_messages,
          salesAnalysis: {}
        }
      }
    }, status: :ok
  end
end
