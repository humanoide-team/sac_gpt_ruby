require 'net/http'
require 'chunky_png'
require 'base64'

class NodeApiClient
  BASE_URL = ENV['NODE_API_URL'].freeze
  SEND_CALLBACK = ENV['SEND_CALLBACK'].freeze
  CALLBACK_URL = ENV['CALLBACK_URL'].freeze

  def self.iniciar_instancia(token, key)
    endpoint = '/instance/init'
    url = "#{BASE_URL}#{endpoint}"
    query_params = { key: key, token: token }

    response = HTTParty.get(url, query: query_params)
    JSON.parse(response.body)
  end

  def self.obter_qr(key)
    url = "#{BASE_URL}/instance/qr"
    query_params = { key: key }

    response = HTTParty.get(url, query: query_params)
    response.body
  end

  def self.enviar_mensagem(numero, mensagem, chave)
    endpoint = '/message/text'
    url = "#{BASE_URL}#{endpoint}"
    query_params = { key: chave }
    body = { id: numero, message: mensagem }

    response = HTTParty.post(url, query: query_params, body: body)
    JSON.parse(response.body)
  end

  def self.send_callback(body)
    return if SEND_CALLBACK == 'false'
    puts '***************************ENVIANDO CALLBACK**************************'
    endpoint = '/api/v1/whatsapp'
    url = "#{CALLBACK_URL}#{endpoint}"

    HTTParty.post(url, body:)
  end
end
