# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3000', '127.0.0.1:3000', 'localhost:3001', '127.0.0.1:3001', 'localhost:4200', '127.0.0.1:4200'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Access-Token', 'Uid', 'Authorization']
  end
end

# resource '*', :headers => :any, :methods => [:get, :post, :put, :patch, :delete, :options, :head], expose: ['Access-Token', 'Uid']
# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins '*'
#     resource '*',
#         headers: :any,
#         methods: [:get, :post, :patch, :put, :options]
#   end

#   allow do
#     origins 'localhost:3000', '127.0.0.1:3000', 'https://mind-api.herokuapp.com', 'https://mind-web-client-dev.herokuapp.com/'
#     resource '/api/v1/*',
#       headers: :any,
#       methods: :any,
#       expose: :any,
#       max_age: 600
#       /http[s]*:\/\/[-a-z0-9_.]*estudologia.com.br/,
#   end
# end
