namespace :transactions_monitoring do
  desc 'Monitoração de Inscricoes'
  task partner_subscription_monitoring: :environment do
    partners = Partner.all

    partners.each do |current_partner|
      current_subscription = current_partner.payment_subscriptions.where(status: :active).first
      next if current_subscription.nil?

      current_subscription.update_galax_pay_payment_subscription_status
    end
  end

  desc ' Parcerio Monitoração de transacoes'
  task partner_transactions_monitoring: :environment do
    partners = Partner.all

    partners.each do |current_partner|
      current_subscription = current_partner.current_subscription || current_partner.payment_subscriptions.last

      if !current_subscription.nil? && current_subscription.status == 'waitingPayment'
        current_subscription&.update_galax_pay_payment_subscription_status
        partners.update(active: true) if current_subscription.status == 'active'
      end

      payments = current_partner.payments.where(status: :waitingPayment)
      payments.each do |payment|
        payment.update_status_galax_pay_payment_status
      end
    end
  end

  desc 'Affiliado Monitoração de transacoes'
  task affiliate_transactions_monitoring: :environment do
    affiliates = Affiliate.all

    affiliates.each do |current_affiliate|
      payments = current_affiliate.affiliate_payments.where(status: :waitingPayment)

      payments.each do |payment|
        payment.update_status_galax_pay_payment_status
      end
    end
  end
end
