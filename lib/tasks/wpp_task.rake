namespace :wpp_task do
  desc 'Enviar resumo semanal para todos os admins'
  task test_connection: :environment do
    partners = Partner.where(wpp_connected: true).where.not(remote_jid: nil).where('last_callbacl_receive < ?',
                                                                                   DateTime.now - 1.hours)

    partners.each do |partner|
      response = NodeApiClient.enviar_mensagem(partner.remote_jid, "Wpp connection test #{DateTime.now}",
                                               partner.instance_key)

      if response['status'] == 'OK'
        puts 'Test messaging send sucessfull'
      else
        "Error Wpp-api: #{response}"
      end
    end
  end

  task send_connection_fail_notification: :environment do
    partners = Partner.where(wpp_connected: false).where('last_callbacl_receive < ?', DateTime.now - 3.hours)
    partners.each(&:send_connection_fail_mail)
  end
end
