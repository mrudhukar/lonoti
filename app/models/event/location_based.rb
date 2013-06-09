class Event::LocationBased < AbstractEvent
  reverse_geocoded_by :lat, :lng

  attr_accessible :lat, :lng, :distance_from_address, :from_address

  validates :lat, :lng, :distance_from_address, presence: true

  after_validation :reverse_geocode
end
