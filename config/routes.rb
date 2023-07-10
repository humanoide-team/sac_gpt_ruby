Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1, defaults: { format: :json } do
      post 'auth_whatsapp', to: 'webhooks#auth_whatsapp'
      post 'whatsapp', to: 'webhooks#whatsapp'

      namespace :admins do
        post 'authenticate', to: 'authentication#authenticate'

        resources :partners
      end

      namespace :partners do
        post 'authenticate', to: 'authentication#authenticate'
        get 'auth_whatsapp', to: 'authentication#auth_whatsapp'

        resources :partners, only: %i[create destroy update]

        resources :partner_details, only: %i[show create destroy update]

        resources :partner_client_messages, only: %i[index]
        get 'partner_client_messages/list_by_client/:client_id', to: 'partner_client_messages#list_by_client'

        resources :partner_clients, only: %i[index destroy]
      end
    end
  end
end
