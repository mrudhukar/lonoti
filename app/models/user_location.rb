class UserLocation < ActiveRecord::Base
  belongs_to :user

  validates :lat, :lng ,:user, :sent_at, presence: true

  attr_accessible :lat, :lng , :sent_at
end
