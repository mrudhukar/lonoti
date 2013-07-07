# For events with locations they are send when we receive a new UserLocation

namespace :events do
  desc "This is for sending event notifications for events without locations attached"
  
  task :send_notifications do
    non_location_events = Event::TimeBased.events_to_trigger(location: false)

    non_location_events.each do |event|
      event.event_users.each do |event_user|
        event_user.send_message_notification()
      end
    end

    location_events = Event::TimeBased.events_to_trigger(location: true)

    location_events.each do |event|
      event.event_users.each do |event_user|
        event_user.send_location_notification()
      end
    end

    Gcm::Notification.send_notifications
  end

end