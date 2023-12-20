Rails.application.routes.draw do

  post 'auth/google_oauth2/callback', to: 'sessions#create'
  get 'auth/failure', to: 'sessions#failure'
  
  namespace :api, defaults: { format: :json } do
    namespace :v1, defaults: { format: :json } do
      post 'whatsapp', to: 'webhooks#whatsapp'

      namespace :admins do
        post 'authenticate', to: 'authentication#authenticate'

        resources :partners

        resources :payment_plans, only: %i[index show create destroy]

        resources :payment_transactions, only: %i[index]
        get 'payment_transactions/:id/by_client', to: 'payment_transactions#by_client'
        get 'payment_transactions/balance_movements', to: 'payment_transactions#balance_movements'
        get 'payment_transactions/balance', to: 'payment_transactions#balance'
        get 'payment_transactions/balance_info', to: 'payment_transactions#balance_info'
      end

      namespace :partners do
        post 'authenticate', to: 'authentication#authenticate'
        get 'auth_whatsapp', to: 'authentication#auth_whatsapp'
        post 'recover_password', to: 'authentication#send_recover_password_mail'
        patch 'recover_password/:id', to: 'authentication#recover_password'

        resources :partners, only: %i[show create destroy update]
        patch 'partners/recover_password', to: 'partners#recover_password'

        post 'partners/calendar_auth', to: 'partners#calendar_token_auth'

        resources :partner_details, only: %i[show create destroy update]

        resources :partner_client_messages, only: %i[index]
        get 'partner_client_messages/list_by_client/:client_id', to: 'partner_client_messages#list_by_client'

        get 'partner_clients/lead_classification/:id', to: 'partner_clients#lead_classification'

        resources :partner_clients, only: %i[index destroy]

        resources :credit_cards, only: %i[index show create destroy]

        resources :payment_plans, only: %i[index show]

        resources :notifications, only: %i[index update]

        get 'payment_subscriptions/last_active_subscription', to: 'payment_subscriptions#last_active_subscription'
        resources :payment_subscriptions, only: %i[index show create destroy]
        put 'payment_subscriptions/:id/cancel', to: 'payment_subscriptions#cancel'

        resources :payment_transactions, only: %i[index]

        post 'support/send_mail', to: 'support#send_mail'

      end
    end
  end
end
