Mailgun.configure do |config|
  config.api_key = ENV['SMTP_SECRET_API_KEY']
end