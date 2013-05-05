class AbstractEvent < ActiveRecord::Base
  self.table_name = 'events'
  module State
    ACTIVE = 0
    INACTIVE = 1
    ARCHIVED = 2
  end

  attr_accessible :title, :message, :trigger_time, :send_location, :repeats_on_week, :lat, :lng, :distance_from_address, :from_address

  belongs_to :user
  has_many :event_users, dependent: :destroy, foreign_key: :event_id

  validates :title, :message, :user, :status, :type, presence: true
  validates :status, inclusion: {in: [State::ACTIVE, State::INACTIVE, State::ARCHIVED] }

  default_scope where("events.status != ?", State::ARCHIVED)
end
