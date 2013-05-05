class Event::TimeBased < AbstractEvent
  validates :trigger_time, :send_location, presence: true
end
