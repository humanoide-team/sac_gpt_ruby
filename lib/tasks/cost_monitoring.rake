namespace :cost_monitoring do
  desc 'Monitoração de custos'
  task partner_cost_monitoring: :environment do
    partners = Partner.all

    partners.each do |current_partner|
      current_subscription = current_partner.payment_subscriptions.where(status: :active).first

      current_mothly_history = current_partner.current_mothly_history

      if current_mothly_history.token_count > current_subscription.max_token_count
        current_partner.update(active: false)
        PartnerMailer._send_exceed_tokens_quota(current_partner).deliver

      elsif ((current_mothly_history.token_count / current_subscription.max_token_count) * 100) >= 90
        PartnerMailer._send_almost_exceed_tokens_quota(current_partner).deliver

      elsif ((current_mothly_history.token_count / current_subscription.max_token_count) * 100) >= 50
        PartnerMailer._send_half_tokens_quota(current_partner).deliver
      end
    end
  end
end
