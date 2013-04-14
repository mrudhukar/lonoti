class UserLocation < ActiveRecord::Base
  attr_accessible :lat, :lng , :sent_at

  reverse_geocoded_by :lat, :lng


  belongs_to :user

  validates :lat, :lng ,:user, :sent_at, presence: true

  #TODO Move this to a delayed job for better performance
  after_validation :reverse_geocode
end
