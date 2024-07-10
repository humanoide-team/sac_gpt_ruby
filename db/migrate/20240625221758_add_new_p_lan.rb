class AddNewPLan < ActiveRecord::Migration[6.1]
  def up
    PaymentPlan.create(
      name: 'Plano Gratuito',
      periodicity: 'monthly',
      quantity: 12,
      additional_info: 'Plano gratuito de teste',
      plan_price_value: '0',
      max_token_count: 10_000,
      cost_per_thousand_toukens: 0,
      disable: false
    )
  end
end
