require 'net/http'
require 'chunky_png'
require 'base64'

class WahaWppApiClient
  BASE_URL = ENV['WPP_API_URL'].freeze
  API_TOKEN = ENV['WPP_API_TOKEN'].freeze
  CALLBACK_URL = ENV['WPP_API_CALLBACK_URL'].freeze
  SEND_CALLBACK = ENV['WPP_API_SEND_CALLBACK'].freeze

  def self.start_session(instance_key)
    url = "#{BASE_URL}/api/sessions/start"

    headers = {
      'X-Api-Key': API_TOKEN
    }

    body = { name: instance_key }

    response = HTTParty.post(url, headers:, body:)

    if response.code == 201
      puts "Resposta do corpo: #{response.message}"
      'SESSION STARTING'
    elsif response.code == 422 && JSON.parse(response.body)['message'].include?('is already started')
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.message}"
      'SESSION ALREADY STARTED'
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.message}"
    end
  end

  def self.close_session(instance_key)
    url = "#{BASE_URL}/api/sessions/stop"

    headers = {
      'X-Api-Key': API_TOKEN
    }

    body = { name: instance_key, logout: true }

    response = HTTParty.post(url, headers:, body:)

    if response.code == 201
      'SESSION CLOSED'
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.message}"
    end
  end

  def self.obter_qr(instance_key)
    url = "#{BASE_URL}/api/#{instance_key}/auth/qr"

    query = { format: 'image' }

    headers = {
      'X-Api-Key': API_TOKEN,
      'Content-Type': 'image/png'
    }

    response = HTTParty.get(url, headers:, query:)
    if response.code == 200
      response.body
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.message}"
    end
  end

  def self.send_text(numero, mensagem, chave)
    url = "#{BASE_URL}/api/sendText"
    headers = {
      'X-Api-Key': API_TOKEN
    }
    body = { chatId: numero, text: mensagem, session: chave }
    response = HTTParty.post(url, headers:, body:)
    if response.code == 201
      response.body
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts "Resposta do corpo: #{response.message}"
    end
  end

  def self.send_callback(body)
    endpoint = '/api/v1/whatsapp'
    url = "#{CALLBACK_URL}#{endpoint}"
    HTTParty.post(url, body:)
  end
end
