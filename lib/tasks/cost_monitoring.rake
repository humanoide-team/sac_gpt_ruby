namespace :cost_monitoring do
  desc 'Monitoração de custos'
  task partner_cost_monitoring: :environment do
    partners = Partner.all

    partners.each do |current_partner|
      current_subscription = current_partner.payment_subscriptions.where(status: :active).first

      current_mothly_history = current_partner.current_mothly_history

      if current_mothly_history.token_count > current_subscription.max_token_count && !current_mothly_history.exceed_mail
        current_partner.update(active: false)
        PartnerMailer._send_exceed_tokens_quota(current_partner).deliver
        current_mothly_history.update(exceed_mail: true)

      elsif ((current_mothly_history.token_count / current_subscription.max_token_count) * 100) >= 90 && !current_mothly_history.almost_exceed
        PartnerMailer._send_almost_exceed_tokens_quota(current_partner).deliver
        current_mothly_history.update(almost_exceed: true)

      elsif ((current_mothly_history.token_count / current_subscription.max_token_count) * 100) >= 50 && !current_mothly_history.half_exceed
        PartnerMailer._send_half_tokens_quota(current_partner).deliver
        current_mothly_history.update(half_exceed: true)

      end
    end
  end
end
