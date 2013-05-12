class EventUser < ActiveRecord::Base
  attr_accessible :email, :phone_number

  belongs_to :event, class_name: "AbstractEvent", foreign_key: :event_id
  belongs_to :user

  validates :event, :phone_number, presence: true
  validates :phone_number, uniqueness: {scope: :event_id }
  validates :user_id, uniqueness: {scope: :event_id }, allow_nil: true
end
