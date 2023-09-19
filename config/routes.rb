Rails.application.routes.draw do
  root to: 'public/home#index'
  devise_for :partners, controllers: {
    passwords: 'partners/passwords'
  }
  
  

  namespace :api, defaults: { format: :json } do
    namespace :v1, defaults: { format: :json } do
      post 'whatsapp', to: 'webhooks#whatsapp'

      namespace :admins do
        post 'authenticate', to: 'authentication#authenticate'

        resources :partners

        resources :payment_plans, only: %i[index show create destroy]
      end

      namespace :partners do
        post 'authenticate', to: 'authentication#authenticate'
        get 'auth_whatsapp', to: 'authentication#auth_whatsapp'

        resources :partners, only: %i[create destroy update]
        patch 'update_password', to: 'partners#update_password'

        resources :partner_details, only: %i[show create destroy update]

        resources :partner_client_messages, only: %i[index]
        get 'partner_client_messages/list_by_client/:client_id', to: 'partner_client_messages#list_by_client'

        resources :partner_clients, only: %i[index destroy]

        resources :credit_cards, only: %i[show create destroy]

        resources :payment_plans, only: %i[index show]

        resources :payment_subscriptions, only: %i[create show]
        put 'payment_subscriptions/:id/cancel', to: 'payment_subscriptions#cancel'
      end
    end
  end
end
