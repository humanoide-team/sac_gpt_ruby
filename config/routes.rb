Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1, defaults: { format: :json } do
      post 'whatsapp', to: 'webhooks#whatsapp'

      namespace :admins do
        post 'authenticate', to: 'authentication#authenticate'

        resources :partners

        resources :payment_plans, only: %i[index show create destroy]

        resources :payment_transactions, only: %i[index]
        get 'payment_transactions/:id/by_client', to: 'payment_transactions#by_client'
      end

      namespace :partners do
        post 'authenticate', to: 'authentication#authenticate'
        get 'auth_whatsapp', to: 'authentication#auth_whatsapp'

        resources :partners, only: %i[create destroy update]

        resources :partner_details, only: %i[show create destroy update]

        resources :partner_client_messages, only: %i[index]
        get 'partner_client_messages/list_by_client/:client_id', to: 'partner_client_messages#list_by_client'

        resources :partner_clients, only: %i[index destroy]

        resources :credit_cards, only: %i[index show create destroy]

        resources :payment_plans, only: %i[index show]

        get 'payment_subscriptions/last_active_subscription', to: 'payment_subscriptions#last_active_subscription'
        resources :payment_subscriptions, only: %i[index show create destroy]
        put 'payment_subscriptions/:id/cancel', to: 'payment_subscriptions#cancel'

        resources :payment_transactions, only: %i[index]
      end
    end
  end
end
