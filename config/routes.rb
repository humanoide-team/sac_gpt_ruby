Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    namespace :v1, defaults: { format: :json } do
      post 'whatsapp', to: 'webhooks#whatsapp'

      namespace :admins do
        post 'authenticate', to: 'authentication#authenticate'

        resources :partners
      end

      namespace :partners do
        post 'authenticate', to: 'authentication#authenticate'

        resources :partners, only: %i[create destroy update]

        resources :partner_details, only: %i[create destroy update]

      end
    end
  end
end
