namespace :payment_transactions do
  desc 'Create subscritions revenues'
  task create_subscription_revenues: :environment do
    payment_subscriptions = PaymentSubscription.includes(:partner).where(status: :active).where.not(partner: { affiliate_id: nil })

    DateTime.now.day
    payment_subscriptions.each do |ps|
      byebug

      last_revenue = ps.revenues.order(:created_at).last
      if last_revenue.nil? || ((!last_revenue.nil? && last_revenue.create_at.month < DateTime.now.month) && ps.first_pay_day_date.day <= DateTime.now.day)
        ps.create_affiliate_revenue
      end
    end
  end
end
