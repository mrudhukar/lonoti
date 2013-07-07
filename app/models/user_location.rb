class UserLocation < ActiveRecord::Base
  attr_accessible :lat, :lng , :sent_at

  reverse_geocoded_by :lat, :lng


  belongs_to :user

  validates :lat, :lng ,:user, :sent_at, presence: true

  #TODO Move this to a delayed job for better performance
  after_validation :reverse_geocode

  after_create :send_event_notification

  def send_event_notification
    owner = self.user
    loc_events = owner.time_events.active.with_location.where(trigger_time: 5.minutes.ago..5.minutes.from_now).
    where("
      (repeats_on IS NOT NULL AND (repeats_on & ? != 0)) 
      OR 
      (repeats_on IS NULL AND trigger_date = ?)", Event::TimeBased.get_weekday_bit, Time.now().beginning_of_day())

    loc_events.each do |event|
      event.event_users.each do |event_user|
        event_user.send_message_notification(self)
      end
    end

    Gcm::Notification.send_notifications
  end
end
