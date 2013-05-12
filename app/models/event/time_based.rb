class Event::TimeBased < AbstractEvent
  validates :trigger_time, presence: true
  validates :send_location, inclusion: {in: [true, false]}
end
