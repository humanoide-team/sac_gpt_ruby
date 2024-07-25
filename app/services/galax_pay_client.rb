require 'net/http'
require 'base64'

class GalaxPayClient
  BASE_URL = ENV['GALAX_PAY_URL'].freeze
  GALAX_HASH = ENV['GALAX_PAY_HASH'].freeze
  GALAX_ID = ENV['GALAX_PAY_ID'].freeze

  def self.create_client(id, name, document, email, phone)
    # https://docs.galaxpay.com.br/customers/create
    data = {
      myId: "sac-gpt-client-#{id}",
      name:,
      document:,
      phones: [phone],
      emails: [
        email
      ]
    }
    puts data
    body = data.to_json

    token = generate_authorization_token

    headers = {
      'Authorization': "Bearer #{token}",
      'Content-Type': 'application/json'
    }
    response = HTTParty.post("#{BASE_URL}/customers", body:, headers:)

    if response.code == 200
      JSON.parse(response.body)['Customer']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.body}"
      JSON.parse(response.body)
    end
  end

  def self.create_client_payment_card(id, number, holder, expiresAt, cvv, galax_pay_id)
    # https://docs.galaxpay.com.br/cards/create
    data = {
      myId: "sac-gpt-credit-card-#{id}",
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
    response = HTTParty.post("#{BASE_URL}/cards/#{galax_pay_id}/galaxPayId", body: body, headers: headers)

    case response.code
    when 200
      JSON.parse(response.body)['Card']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.body}"
      nil
    end
  end

  def self.create_payment_plan(id, name, periodicity, quantity, additionalInfo, plan_price_payment, plan_price_value)
    # https://docs.galaxpay.com.br/plans/create
    data = {
      myId: "sac-gpt-payment-plan-#{id}",
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
      JSON.parse(response.body)['Plan']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.body}"
    end
  end

  def self.list_payment_subscription(galax_pay_id)
    # https://docs-celcash.celcoin.com.br/subscriptions/list

    token = generate_authorization_token

    headers = {
      'Authorization': "Bearer #{token}",
      'Content-Type': 'application/json'
    }
    response = HTTParty.get("#{BASE_URL}/subscriptions?galaxPayIds=#{galax_pay_id}&startAt=0&limit=10&", headers:)
    if response.code == 200
      JSON.parse(response.body)['Subscriptions'].first
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.body}"
    end
  end

  def self.create_payment_subscription(id, planMyId, planGalaxPayId, firstPayDayDate, additionalInfo, mainPaymentMethodId, customer, credit_card_my_id)
    # https://docs.galaxpay.com.br/subscriptions/create-with-plan
    data = {
      myId: "sac-gpt-payment-subscription-#{id}",
      planMyId:,
      planGalaxPayId:,
      firstPayDayDate:,
      additionalInfo:,
      mainPaymentMethodId:,
      Customer: {
          myId: customer.galax_pay_my_id,
          galaxPayId: customer.galax_pay_id,
          name: customer.name,
          document: customer.document,
          emails: [
            customer.email
          ],
          phones: [
            customer.contact_number
          ],
      },
      PaymentMethodCreditCard: {
        Card: {
          myId: credit_card_my_id,
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
      JSON.parse(response.body)['Subscription']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.body}"
    end
  end

  def self.edit_payment_subscription_credit_card(subscription_galax_pay_id, value, mainPaymentMethodId, credit_card_my_id)
    # https://docs.galaxpay.com.br/subscriptions/edit-value
    data = {
      value:,
      mainPaymentMethodId:,
      PaymentMethodCreditCard: {
        Card: {
          myId: credit_card_my_id,
        }
      }
    }
    body = data.to_json

    token = generate_authorization_token

    headers = {
      'Authorization': "Bearer #{token}",
      'Content-Type': 'application/json'
    }
    response = HTTParty.put("#{BASE_URL}/subscriptions/#{subscription_galax_pay_id}/galaxPayId", body:, headers:)
    if response.code == 200
      JSON.parse(response.body)['Subscription']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.body}"
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
      JSON.parse(response.body)['type']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.body}"
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
      JSON.parse(response.body)['type']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.body}"
    end
  end

  def self.list_payment(galax_pay_id)
    # https://docs-celcash.celcoin.com.br/individual-charges/list
    token = generate_authorization_token

    headers = {
      'Authorization': "Bearer #{token}",
      'Content-Type': 'application/json'
    }
    response = HTTParty.get("#{BASE_URL}/charges?galaxPayIds=#{galax_pay_id}&startAt=0&limit=10&", headers:)
    if response.code == 200
      JSON.parse(response.body)['Charges'].first
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.body}"
    end
  end

  def self.create_payment(id, payday, additionalInfo, mainPaymentMethodId, credit_card_my_id, value, customer)
    # https://docs-celcash.celcoin.com.br/individual-charges/create/request
    data = {
      myId: "sac-gpt-payment-#{id}",
      value:,
      additionalInfo:,
      payday:,
      payedOutsideGalaxPay: false,
      mainPaymentMethodId:,
      Customer: {
        myId: customer.galax_pay_my_id,
        name: customer.name,
        document: customer.document,
        emails: [
          customer.email
        ],
        phones: [
          customer.contact_number
        ],
      },
      PaymentMethodCreditCard: {
        Card: {
          myId: credit_card_my_id
        }
      }
    }
    body = data.to_json

    token = generate_authorization_token

    headers = {
      'Authorization': "Bearer #{token}",
      'Content-Type': 'application/json'
    }
    response = HTTParty.post("#{BASE_URL}/charges", body:, headers:)
    if response.code == 200
      JSON.parse(response.body)['Charge']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.body}"
    end
  end

  def self.get_transactions_by_client(customerGalaxPayId, status, startAt, limit)
    # https://docs.galaxpay.com.br/transactions/list

    token = generate_authorization_token

    headers = {
      'Authorization': "Bearer #{token}",
      'Content-Type': 'application/json'
    }
    response = HTTParty.get("#{BASE_URL}/transactions?status=#{status}&customerGalaxPayIds=#{customerGalaxPayId}&startAt=#{startAt}&limit=#{limit}&order=createdAt.desc", headers:)
    if response.code == 200
      JSON.parse(response.body)['Transactions']
    else
      puts "Resposta do corpo: #{response.body}"
      puts "Falha na requisição. Código de status: #{response.code}"
    end
  end

  def self.get_all_transactions(status, startAt, limit)
    # https://docs.galaxpay.com.br/transactions/list

    token = generate_authorization_token

    headers = {
      'Authorization': "Bearer #{token}",
      'Content-Type': 'application/json'
    }
    response = HTTParty.get("#{BASE_URL}/transactions?status=#{status}&startAt=#{startAt}&limit=#{limit}&order=createdAt.desc", headers:)
    if response.code == 200
      JSON.parse(response.body)['Transactions']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.body}"
    end
  end

  def self.get_balance_movements(initialDate, finalDate)
    # https://docs.galaxpay.com.br/balance/list

    token = generate_authorization_token

    headers = {
      'Authorization': "Bearer #{token}",
      'Content-Type': 'application/json'
    }
    response = HTTParty.get("#{BASE_URL}/company/balance/movements?initialDate=#{initialDate}&finalDate=#{finalDate}", headers:)
    if response.code == 200
      JSON.parse(response.body)
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.body}"
    end
  end

  def self.get_balance()
    #https://docs.galaxpay.com.br/balance/get-balance

    token = generate_authorization_token

    headers = {
      'Authorization': "Bearer #{token}",
      'Content-Type': 'application/json'
    }
    response = HTTParty.get("#{BASE_URL}/company/balance", headers:)
    if response.code == 200
      JSON.parse(response.body)
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.body}"
    end
  end

  def self.generate_authorization_token
    # https://docs.galaxpay.com.br/auth/token
    data = {
      grant_type: 'authorization_code',
      scope: 'customers.read customers.write plans.read plans.write transactions.read transactions.write webhooks.write cards.read cards.write card-brands.read subscriptions.read subscriptions.write charges.read charges.write boletos.read carnes.read payment-methods.read balance.read'
    }
    body = data.to_json
    encoded_string = Base64.strict_encode64("#{GALAX_ID}:#{GALAX_HASH}")

    headers = {
      'Authorization': "Basic #{encoded_string}",
      'Content-Type': 'application/json'
    }

    response = HTTParty.post("#{BASE_URL}/token", body:, headers:)
    if response.code == 200
      JSON.parse(response.body)['access_token']
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.body}"
    end
  end
end
