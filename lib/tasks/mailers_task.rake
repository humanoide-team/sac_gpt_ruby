namespace :email do
  desc 'Enviar resumo semanal para todos os admins'
  task weekly_summary: :environment do
    return unless DateTime.now.wday == 1

    admins = Admin.all

    admins.each do |admin|
      admin.weekly_summary_mail
    end
  end
end
