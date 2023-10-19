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
      summary: summary,
      description: description,
    )

    @calendar_service = Google::Apis::CalendarV3::CalendarService.new
    @calendar_service.authorization = partner.calendar_token
    @calendar_service.insert_event('primary', event)
  end
end
