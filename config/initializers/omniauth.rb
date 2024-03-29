# config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], {
    scope: 'calendar, profile,email',
    access_type: 'offline',
    prompt: 'consent',
    provider_ignores_state: true
  }
end
