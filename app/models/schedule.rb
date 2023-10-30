require 'google/apis/calendar_v3'
require 'googleauth'

class Schedule < ApplicationRecord
  belongs_to :partner
  belongs_to :partner_client

  after_create :create_event

  def create_event
    event = Google::Apis::CalendarV3::Event.new(
      start: Google::Apis::CalendarV3::EventDateTime.new(date_time: date_time_start),
      end: Google::Apis::CalendarV3::EventDateTime.new(date_time: date_time_end),
      summary:,
      description:
    )

    @calendar_service = Google::Apis::CalendarV3::CalendarService.new
    @calendar_service.authorization = partner.calendar_token
    @calendar_service.insert_event('primary', event)
  end

  def create
    puts "###############################Creating a new Calendar event"###############################"
    client = get_google_calendar_client(partner)
    puts client
    puts "###############################Google calendar Client############################################"
    event = get_event
    puts event
    puts "###############################Google Calendar Event"###############################"

    client.insert_event('primary', event, conference_data_version: 1)
    puts "Sucess Event created"
  end

  def get_google_calendar_client(partner)
    client = Google::Apis::CalendarV3::CalendarService.new
    return unless partner.present? && partner.access_token.present? && partner.refresh_token.present?

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

      unless partner.present?
        client.authorization.refresh!
        partner.update_attributes(
          access_token: client.authorization.access_token,
          refresh_token: client.authorization.refresh_token,
          expires_at: client.authorization.expires_at.to_i
        )
      end
    rescue StandardError => e
      errors.add(:base, 'Your token has been expired. Please login again with google.')
      throw :abort
    end
    client
  end

  private

  def get_event
    attendees = partner_client.email

    Google::Apis::CalendarV3::Event.new({
                                                  summary: ,
                                                  location: '',
                                                  description:,
                                                  start: {
                                                    date_time: Google::Apis::CalendarV3::EventDateTime.new(date_time: date_time_start)
                                                  },
                                                  end: {
                                                    date_time: Google::Apis::CalendarV3::EventDateTime.new(date_time: date_time_end)
                                                  },
                                                  attendees:,
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
                                                })
  end
end

# Schedule.create(summary: "teste", description: "teste teste", date_time_start: "2023-10-30T19:00:31.172Z", date_time_end: "2023-10-30T20:00:31.172Z", partner_id: 30, partner_client_id: 84)
# Schedule.create(summary: "teste", description: "teste teste", date_time_start: "2023-10-30T20:00:31.172Z", date_time_end: "2023-10-30T21:00:31.172Z", partner_id: 26, partner_client_id: 1)