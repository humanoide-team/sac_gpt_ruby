require 'google/apis/calendar_v3'
require 'google/api_client/client_secrets'

class Schedule < ApplicationRecord
  belongs_to :partner
  belongs_to :partner_client, optional: true
  belongs_to :schedule_setting, optional: true

  before_create :create_event

  def create_event
    puts '#########################Iniciando criacao de evento########################'
    throw :abort if partner.access_token.nil?

    client = get_google_calendar_client(partner)
    event = get_event

    begin
      puts '#########################Inserindo Evento na agenda########################'
      resposta = client.insert_event(partner.schedule_setting.google_agenda_id, event, send_notifications: true, conference_data_version: 1)
      puts resposta
    rescue StandardError => e
      puts e
      errors.add(:base, 'Fail to create Event.')
      throw :abort
    end
    puts 'Sucess Event created'
  end

  def get_google_calendar_client(partner)
    puts '##########################Montando Calendar client##############################'

    client = Google::Apis::CalendarV3::CalendarService.new
    throw :abort unless partner.present? && partner.access_token.present? && partner.refresh_token.present?

    secrets = Google::APIClient::ClientSecrets.new({
                                                     'web' => {
                                                       'access_token' => partner.access_token,
                                                       'refresh_token' => partner.refresh_token,
                                                       'client_id' => ENV['GOOGLE_CLIENT_ID'],
                                                       'client_secret' => ENV['GOOGLE_CLIENT_SECRET']
                                                     }
                                                   })
    begin
      client.authorization = secrets.to_authorization
      client.authorization.grant_type = 'refresh_token'
      if partner.expires_at.nil? || DateTime.now >= partner.expires_at
        client.authorization.refresh!
        partner.update(
          access_token: client.authorization.access_token,
          refresh_token: client.authorization.refresh_token,
          expires_at: client.authorization.expires_at
        )
      end
    rescue StandardError => e
      puts e
      errors.add(:base, 'Your token has been expired. Please login again with google.')
      throw :abort
    end
    client
  end

  def get_event
    puts '########################3Montando Evento###########################'

    Google::Apis::CalendarV3::Event.new(
      summary:,
      location: '',
      description:,
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: date_time_start.iso8601(3),
        time_zone: 'America/Sao_Paulo'
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: date_time_end.iso8601(3),
        time_zone: 'America/Sao_Paulo'
      ),
      attendees: [
        {
          email: partner_client.nil? ? partner&.partner_test_bot_lead&.test_bot_mail : partner_client.email
        }
      ],
      reminders: {
        use_default: false,
        overrides: [
          Google::Apis::CalendarV3::EventReminder.new(
            reminder_method: 'popup', minutes: 10
          ),
          Google::Apis::CalendarV3::EventReminder.new(
            reminder_method: 'email', minutes: 20
          )
        ]
      },
      conference_data: {
        create_request: {
          request_id: "#{id}-sac-meeting-schedule"
        },
        conference_solution_key: {
          type: 'hangoutsMeet'
        }
      },
      notification_settings: {
        notifications: [
          { type: 'event_creation', method: 'email' },
          { type: 'event_change', method: 'email' },
          { type: 'event_cancellation', method: 'email' },
          { type: 'event_response', method: 'email' }
        ]
      }, 'primary': true
    )
  end
end
