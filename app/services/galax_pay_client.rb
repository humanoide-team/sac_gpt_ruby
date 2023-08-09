require 'net/http'
require 'base64'

class GalaxPayClient
  BASE_URL = ENV['GALAX_PAY_URL'].freeze
  GALAX_HASH = ENV['GALAX_PAY_HASH'].freeze
  GALAX_ID = ENV['GALAX_PAY_ID'].freeze

  def self.create_client(id, name, document, email, phone)
    # https://docs.galaxpay.com.br/customers/create
    data = {
      myId: id,
      name:,
      document:,
      phones: [phone],
      email: [
        email
      ]
    }
    body = data.to_json

    token = generate_authorization_token

    headers = {
      'Authorization': "Bearer #{token}",
      'Content-Type': 'application/json'
    }
    response = HTTParty.post("#{BASE_URL}/customers", body:, headers:)

    if response.code == 200
      puts 'Requisição bem-sucedida!'
      puts 'Corpo da resposta:'
      JSON.parse(response.body)['Customer']['galaxPayId']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "#{response.body}"
    end
  end

  def self.create_client_payment_card(id, number, holder, expiresAt, cvv, galax_pay_id)
    # https://docs.galaxpay.com.br/cards/create
    data = {
      myId: "sac-gpt-#{id}",
      number:,
      holder:,
      expiresAt:,
      cvv:,
    }
    body = data.to_json

    token = generate_authorization_token

    headers = {
      'Authorization': "Bearer #{token}",
      'Content-Type': 'application/json'
    }
    response = HTTParty.post("#{BASE_URL}/cards/#{galax_pay_id}/galaxPayId", body:, headers:)
    if response.code == 200
      puts 'Requisição bem-sucedida!'
      JSON.parse(response.body)['Card']['galaxPayId']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "#{response.body}"
    end
  end

  def self.create_payment_plan(id, name, periodicity, quantity, additionalInfo, plan_price_payment, plan_price_value)
    # https://docs.galaxpay.com.br/plans/create
    data = {
      myId: "sac-gpt-#{id}",
      name:,
      periodicity:,
      quantity:,
      additionalInfo:,
      PlanPrices: [
        {
          payment: plan_price_payment,
          value: plan_price_value
        }
      ]
    }
    body = data.to_json

    token = generate_authorization_token

    headers = {
      'Authorization': "Bearer #{token}",
      'Content-Type': 'application/json'
    }

    response = HTTParty.post("#{BASE_URL}/plans", body:, headers:)
    if response.code == 200
      puts 'Requisição bem-sucedida!'
      JSON.parse(response.body)['Plan']['galaxPayId']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
    end
  end

  def self.create_payment_subscription(id, planMyId, firstPayDayDate, additionalInfo, mainPaymentMethodId, customer, credit_card_my_id)
    # https://docs.galaxpay.com.br/subscriptions/create-with-plan
    data = {
      myId: "sac-gpt-#{id}",
      planMyId:,
      firstPayDayDate:,
      additionalInfo:,
      mainPaymentMethodId:,
      Customer: {
          myId: "sac-gpt-#{customer.id}",
          name: customer.name,
          document: customer.document,
          email: [
            customer.email
          ]
      },
      PaymentMethodCreditCard: {
        Card: {
          myId: "sac-gpt-#{credit_card_my_id}",
        }
      }
    }
    body = data.to_json

    token = generate_authorization_token

    headers = {
      'Authorization': "Bearer #{token}",
      'Content-Type': 'application/json'
    }
    response = HTTParty.post("#{BASE_URL}/subscriptions", body:, headers:)
    if response.code == 200
      puts 'Requisição bem-sucedida!'
      JSON.parse(response.body)['Subscription']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
    end
  end

  def self.cancel_payment_subscription(subscription_galax_pay_id)
    # https://docs.galaxpay.com.br/subscriptions/cancel

    token = generate_authorization_token

    headers = {
      'Authorization': "Bearer #{token}",
      'Content-Type': 'application/json'
    }
    response = HTTParty.delete("#{BASE_URL}/subscriptions/#{subscription_galax_pay_id}/galaxPayId", headers:)
    if response.code == 200
      puts 'Requisição bem-sucedida!'
      JSON.parse(response.body)['type']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
    end
  end

  def self.cancel_payment_transaction(transaction_galax_pay_id)
    # https://docs.galaxpay.com.br/subscriptions/cancel-transaction

    token = generate_authorization_token

    headers = {
      'Authorization': "Bearer #{token}",
      'Content-Type': 'application/json'
    }
    response = HTTParty.delete("#{BASE_URL}/transactions/#{transaction_galax_pay_id}/galaxPayId", headers:)
    if response.code == 200
      puts 'Requisição bem-sucedida!'
      JSON.parse(response.body)['type']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
    end
  end

  def self.get_transactions_by_client(customerGalaxPayId)
    # https://docs.galaxpay.com.br/transactions/list

    token = generate_authorization_token

    headers = {
      'Authorization': "Bearer #{token}",
      'Content-Type': 'application/json'
    }
    response = HTTParty.get("#{BASE_URL}/transactions?customerGalaxPayIds=#{customerGalaxPayId}&startAt=0&limit=100", headers:)
    if response.code == 200
      puts 'Requisição bem-sucedida!'
      JSON.parse(response.body)['Transactions']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
    end
  end

  def self.generate_authorization_token
    # https://docs.galaxpay.com.br/auth/token
    data = {
      grant_type: 'authorization_code',
      scope: 'customers.read customers.write plans.read plans.write transactions.read transactions.write webhooks.write cards.read cards.write card-brands.read subscriptions.read subscriptions.write charges.read charges.write boletos.read carnes.read payment-methods.read'
    }
    body = data.to_json
    # encoded_string = Base64.encode64("#{GALAX_ID}:#{GALAX_HASH}")
    encoded_string = 'NTQ3Mzo4M013NXU4OTg4UWo2ZlpxUzRaOEs3THpPbzFqMjhTNzA2UjBCZUZl'

    headers = {
      'Authorization': "Basic #{encoded_string}",
      'Content-Type': 'application/json'
    }

    response = HTTParty.post("#{BASE_URL}/token", body:, headers:)
    if response.code == 200
      puts 'Requisição bem-sucedida!'
      puts 'Corpo da resposta:'
      JSON.parse(response.body)['access_token']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
    end
  end
end
