namespace :cost_monitoring do
  desc 'Monitoração de custos'
  task partner_cost_monitoring: :environment do
    partners = Partner.all

    partners.each do |current_partner|
      current_subscription = current_partner.payment_subscriptions.where(status: :active).first

      next if current_subscription.nil?

      current_mothly_history = current_partner.current_mothly_history

      current_extra_token = current_partner.extra_tokens.sum(:token_quantity)

      total_mothly_token = current_subscription.max_token_count + current_extra_token

      next if current_subscription.max_token_count.nil? || current_subscription.max_token_count.zero?

      next if current_subscription.max_token_count.nil? || current_subscription.max_token_count.zero?

      next if current_mothly_history.token_count.zero?

      if current_mothly_history.token_count > current_subscription.max_token_count && current_partner.active && current_extra_token.zero?
        current_partner.update(active: false)
        unless current_mothly_history.exceed_mail
          PartnerMailer._send_exceed_tokens_quota(current_partner).deliver
          current_mothly_history.update(exceed_mail: true)
        end
      elsif ((current_mothly_history.token_count / current_subscription.max_token_count) * 100) >= 90 && current_partner.active && current_extra_token.zero?
        unless current_mothly_history.almost_exceed
          PartnerMailer._send_almost_exceed_tokens_quota(current_partner).deliver
          current_mothly_history.update(almost_exceed: true)
        end
      elsif ((current_mothly_history.token_count / current_subscription.max_token_count) * 100) >= 50 && current_partner.active && current_extra_token.zero?
        unless current_mothly_history.half_exceed
          PartnerMailer._send_half_tokens_quota(current_partner).deliver
          current_mothly_history.update(half_exceed: true)
        end
      elsif current_partner.active && !current_extra_token.zero? && current_mothly_history.token_count > total_mothly_token
        current_partner.update(active: false)
        unless current_mothly_history.exceed_extra_token_mail
          PartnerMailer._send_exceed_extra_tokens_quota(current_partner).deliver
          current_mothly_history.update(exceed_extra_token_mail: true)
        end
      elsif current_partner.active && !current_extra_token.zero? && (((current_mothly_history.token_count - current_subscription.max_token_count) / current_extra_token) * 100) > 90
        unless current_mothly_history.extra_token_almost_exceed
          PartnerMailer._send_almost_exceed_extra_tokens_quota(current_partner).deliver
          current_mothly_history.update(extra_token_almost_exceed: true)
        end
      elsif current_partner.active && !current_extra_token.zero? && (((current_mothly_history.token_count - current_subscription.max_token_count) / current_extra_token) * 100) > 50
        unless current_mothly_history.extra_token_half_exceed
          PartnerMailer._send_half_extra_tokens_quota(current_partner).deliver
          current_mothly_history.update(extra_token_half_exceed: true)
        end
      end
    end
  end
end
