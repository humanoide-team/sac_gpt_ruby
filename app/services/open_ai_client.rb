require 'openai'
require 'net/http'
require 'base64'

class OpenAiClient
  OPEN_AI_KEY = ENV['OPENAI_API_KEY'].freeze
  BASE_URL = 'https://api.openai.com'

  def self.text_generation(pergunta, historico_conversa, model)
    client = OpenAI::Client.new(access_token: OPEN_AI_KEY)
    messages = historico_conversa + [{ role: 'user', content: pergunta }]
    client.chat(
      parameters: {
        model:,
        messages:,
        max_tokens: 500,
        n: 1,
        stop: nil,
        temperature: 0.7
      }
    )
  rescue StandardError => e
    puts e
    puts response
    'Falha em gerar resposta'
  end

  def self.upload_file(file)
    # https://platform.openai.com/docs/api-reference/files/create
    body = {
      purpose: 'assistants',
      file:
    }

    headers = {
      'Authorization': "Bearer #{OPEN_AI_KEY}",
      'Content-Type': 'multipart/form-data'
    }

    response = HTTParty.post("#{BASE_URL}/v1/files", body:, headers:)
    if response.code == 200
      puts 'Requisição bem-sucedida!'
      puts JSON.parse(response.body)
      JSON.parse(response.body)
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts JSON.parse(response.body)
    end
  end

  def self.delete_file(file_id)
    # https://platform.openai.com/docs/assistants/tools/knowledge-retrieval

    headers = {
      'Authorization': "Bearer #{OPEN_AI_KEY}",
    }

    response = HTTParty.delete("#{BASE_URL}/v1/files/#{file_id}", headers:)
    if response.code == 200
      puts 'Requisição bem-sucedida!'
      puts JSON.parse(response.body)
      JSON.parse(response.body)
    else
      puts "Falha na requisição. Código de status: #{response.code}"
    end
  end

  def self.create_assistent_file(assistant_id, file_id)
    # https://platform.openai.com/docs/api-reference/assistants/createAssistantFile

    body = {
      file_id: file_id,
    }.to_json

    headers = {
      'Authorization': "Bearer #{OPEN_AI_KEY}",
      'Content-Type': 'application/json',
      'OpenAI-Beta': 'assistants=v1'
    }

    response = HTTParty.post("#{BASE_URL}/v1/assistants/#{assistant_id}/files", body:, headers:)
    if response.code == 200
      puts 'Requisição bem-sucedida!'
      puts JSON.parse(response.body)
      JSON.parse(response.body)
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts response.body
    end
  end

  def self.delete_assistent_file(assistant_id, file_id)
    # https://platform.openai.com/docs/api-reference/assistants/deleteAssistantFile

    headers = {
      'Authorization': "Bearer #{OPEN_AI_KEY}",
      'Content-Type': 'application/json',
      'OpenAI-Beta': 'assistants=v1'
    }

    response = HTTParty.delete("#{BASE_URL}/v1/assistants/#{assistant_id}/files/#{file_id}", headers:)
    if response.code == 200
      puts 'Requisição bem-sucedida!'
      puts JSON.parse(response.body)
      JSON.parse(response.body)
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts response.body
    end
  end

  def self.create_assistent(instructions, name)
    # https://platform.openai.com/docs/api-reference/assistants/createAssistant
    data = {
      instructions:,
      name:,
      tools: [
        { "type": 'code_interpreter' },
        { "type": 'retrieval' }
      ],
      model: 'gpt-4-turbo-preview'
    }

    body = data.to_json

    headers = {
      'Authorization': "Bearer #{OPEN_AI_KEY}",
      'Content-Type': 'application/json',
      'OpenAI-Beta': 'assistants=v1'
    }

    response = HTTParty.post("#{BASE_URL}/v1/assistants", body:, headers:)
    if response.code == 200
      puts 'Requisição bem-sucedida!'
      puts JSON.parse(response.body)
      JSON.parse(response.body)
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts response.body
    end
  end

  def self.create_thread
    # https://platform.openai.com/docs/api-reference/threads/createThread

    headers = {
      'Authorization': "Bearer #{OPEN_AI_KEY}",
      'Content-Type': 'application/json',
      'OpenAI-Beta': 'assistants=v1'
    }

    response = HTTParty.post("#{BASE_URL}/v1/threads", headers:)
    if response.code == 200
      puts 'Requisição bem-sucedida!'
      puts JSON.parse(response.body)
      JSON.parse(response.body)
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts response.body
    end
  end

  def self.create_message(thread_id, message)
    # https://platform.openai.com/docs/api-reference/messages/createMessage

    headers = {
      'Authorization': "Bearer #{OPEN_AI_KEY}",
      'Content-Type': 'application/json',
      'OpenAI-Beta': 'assistants=v1'
    }

    body = message.to_json

    response = HTTParty.post("#{BASE_URL}/v1/threads/#{thread_id}/messages", body:, headers:)
    if response.code == 200
      puts 'Requisição bem-sucedida!'
      puts JSON.parse(response.body)
      JSON.parse(response.body)
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts response.body
    end
  end

  def self.run_thread(assistant_id, thread_id)
    # https://platform.openai.com/docs/api-reference/runs/createRun
    data = {
      assistant_id:
    }

    body = data.to_json

    headers = {
      'Authorization': "Bearer #{OPEN_AI_KEY}",
      'Content-Type': 'application/json',
      'OpenAI-Beta': 'assistants=v1'
    }

    response = HTTParty.post("#{BASE_URL}/v1/threads/#{thread_id}/runs", body:, headers:)
    if response.code == 200
      puts 'Requisição bem-sucedida!'
      puts JSON.parse(response.body)
      JSON.parse(response.body)
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts response.body
    end
  end

  def self.retrieve_run(thread_id, run_id)
    # https://platform.openai.com/docs/api-reference/runs/getRun

    headers = {
      'Authorization': "Bearer #{OPEN_AI_KEY}",
      'Content-Type': 'application/json',
      'OpenAI-Beta': 'assistants=v1'
    }

    response = HTTParty.get("#{BASE_URL}/v1/threads/#{thread_id}/runs/#{run_id}", headers:)
    if response.code == 200
      puts 'Requisição bem-sucedida!'
      puts JSON.parse(response.body)
      JSON.parse(response.body)
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts response.body
    end
  end

  def self.thread_messages(thread_id )
    # https://platform.openai.com/docs/api-reference/runs/createRun

    headers = {
      'Authorization': "Bearer #{OPEN_AI_KEY}",
      'Content-Type': 'application/json',
      'OpenAI-Beta': 'assistants=v1'
    }

    response = HTTParty.get("#{BASE_URL}/v1/threads/#{thread_id}/messages", headers:)
    if response.code == 200
      puts 'Requisição bem-sucedida!'
      JSON.parse(response.body)
    else
      puts "Falha na requisição. Código de status: #{response.code}"
      puts response.body
    end
  end
end
