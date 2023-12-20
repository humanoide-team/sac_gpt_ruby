class Api::V1::Partners::PartnerReportsController < ApiPartnerController
  def index
    # Overview
    partner_leads = @current_partner.partner_client_leads
    lead_count = partner_leads.count
    client_scores = partner_leads.map do |pl|
      {
        client: PartnerClientSerializer.new(pl.partner_client),
        clientScore: pl.lead_score
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
          usageStatistics: {},
          salesAnalysis: {}
        }
      }
    }, status: :ok
  end
end
