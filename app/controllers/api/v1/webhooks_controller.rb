require "openai"

class Api::V1::WebhooksController < ApiController
  def whatsapp
    @historico_por_telefone = {}
    @ultima_mensagem_por_telefone = {}
    @tempos_recebimento_mensagens = {}
    @mensagens_processadas = []

    nome_atendente = ENV['NOME_ATENDENTE']
    nome_empresa = ENV['NOME_EMPRESA']
    nicho_empresa = ENV['NICHO_EMPRESA']
    regiao_atendida = ENV['REGIAO_ATENDIDA']
    servicos_empresa = ENV['SERVICOS_EMPRESA']
    produtos_empresa = ENV['PRODUTOS_EMPRESA']
    contato_empresa = ENV['SITE_EMPRESA']
    objetivo_empresa = ENV['OBJETIVOS_EMPRESA']

    historico_conversa = [
      {
        role: "system",
        content: "Você é, com o nome de #{nome_atendente}, um assistente comercial da empresa #{nome_empresa}, especializada no nicho #{nicho_empresa} e atuando exclusivamente em #{regiao_atendida}. Seu objetivo é compreender as necessidades do cliente e como os serviços e produtos da #{nome_empresa} podem ajudá-los. Os serviços são: #{servicos_empresa}, os produtos são: #{produtos_empresa} e o site da empresa é #{contato_empresa}. Atenção, não responda com mais de 50 palavras. Comece apresentando-se e perguntando o nome do cliente, se necessário. Foque em identificar as necessidades específicas e os desafios do cliente, fazendo no máximo uma pergunta por mensagem. Após entender claramente as necessidades do cliente, proponha #{objetivo_empresa}. Certifique-se de obter o email do cliente e marcar uma reunião online, ao marcar uma reunião defina um dia da semana e um expediente, de tarde ou de noite. Mantenha um tom persuasivo e estilo conversacional porém seja direto e conciso."
      }
    ]

    if params["message"]["from"] == "tide-gasoline"
      render json: { status: "OK", current_date: DateTime.now.to_s, params: params }
    end

    pergunta_usuario = params["message"]["contents"][0]["text"]

    if mensagem_ja_processada(pergunta_usuario)
      render json: { status: "OK", current_date: DateTime.now.to_s, params: params }
    end

    numero_telefone = params["message"]["from"]

    gravar_conversa_em_arquivo(numero_telefone, pergunta_usuario, "user")

    unless historico_por_telefone.include?(numero_telefone)
      @historico_por_telefone[numero_telefone] = historico_conversa.dup
    end

    historico_atual = historico_por_telefone[numero_telefone]
    historico_atual << { "role" => "user", "content" => pergunta_usuario }

    tempos_recebimento_mensagens[numero_telefone] = DateTime.now
    Thread.new { aguardar_e_enviar_resposta(numero_telefone) }

    render json: { status: "OK", current_date: DateTime.now.to_s, params: params }
  end

  def gerar_resposta(pergunta, historico_conversa)
    unless pergunta.is_a?(String) && !pergunta.empty?
      return "Desculpe, não entendi a sua pergunta."
    end

    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

    response = client.chat(
      parameters: {
        model: "gpt-4",
        messages: historico_conversa + [{ "role" => "user", "content" => pergunta }],
        max_tokens: 1500,
        n: 1,
        stop: nil,
        temperature: 0.7
      }
    )

    resposta = response.choices[0].message["content"].strip
    return resposta
  end

  def pos_processamento(resposta)
    resposta = resposta.gsub("\n", " ").strip
    return resposta
  end

  def gravar_conversa_em_arquivo(numero_telefone, mensagem, role)
    nome_arquivo = "conversa_#{numero_telefone}.txt"
    File.open(nome_arquivo, "a") do |file|
      if role == "user"
        file.write("Usuário: #{mensagem}\n")
        ultima_mensagem_por_telefone[numero_telefone] = DateTime.now
      elsif role == "assistant"
        file.write("Assistente: #{mensagem}\n")
      end
    end
  end

  def aguardar_e_enviar_resposta(numero_telefone, tempo_espera = 15)
    zenvia_sandbox_api_url = "https://api.zenvia.com/v2/channels/whatsapp/messages"

    sleep(tempo_espera)
    if tempos_recebimento_mensagens.include?(numero_telefone)
      ultimo_tempo = tempos_recebimento_mensagens[numero_telefone]
      tempo_atual = DateTime.now

      if tempo_atual - ultimo_tempo >= Rational(tempo_espera, 86400)
        historico_atual = historico_por_telefone[numero_telefone]
        pergunta_usuario = historico_atual[-1]["content"]
        resposta = gerar_resposta(pergunta_usuario, historico_atual)
        resposta = pos_processamento(resposta)
        historico_atual << { "role" => "assistant", "content" => resposta }

        gravar_conversa_em_arquivo(numero_telefone, resposta, "assistant")

        headers = {
          "Content-Type" => "application/json",
          "X-API-TOKEN" => ENV['ZENVIA_API_KEY']
        }
        data = {
          "from" => "tide-gasoline",
          "to" => numero_telefone,
          "contents" => [
            {
              "type" => "text",
              "text" => resposta
            }
          ]
        }

        response = HTTParty.post(zenvia_sandbox_api_url,
                                 body: data.to_json, headers: headers)
        if response.code != 200
          puts "Erro na API do Zenvia: #{response.body}"
        end
        response.raise_for_status
      end
    end
  end

  def gravar_conversa_em_arquivo(numero_telefone, mensagem, role)
    nome_arquivo = "conversa_#{numero_telefone}.txt"
    File.open(nome_arquivo, "a") do |file|
      if role == "user"
        file.write("Usuário: #{mensagem}\n")
        ultima_mensagem_por_telefone[numero_telefone] = DateTime.now
      elsif role == "assistant"
        file.write("Assistente: #{mensagem}\n")
      end
    end
  end

  def mensagem_ja_processada(conteudo_mensagem)
    if @mensagens_processadas.include?(conteudo_mensagem)
      return true
    else
      @mensagens_processadas.add(conteudo_mensagem)
      return false
    end
  end
end
