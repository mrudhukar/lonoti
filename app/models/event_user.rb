class EventUser < ActiveRecord::Base
  attr_accessible :email, :phone_number

  belongs_to :event, class_name: "AbstractEvent", foreign_key: :event_id
  belongs_to :user

  has_many :notifications, dependent: :destroy

  validates :event, :phone_number, presence: true
  validates :phone_number, uniqueness: {scope: :event_id }
  validates :user_id, uniqueness: {scope: :event_id }, allow_nil: true

  def send_notification
    event = self.event
    recent_notification = self.notifications.order("id DESC").first

    unless recent_notification && recent_notification.created_at.beginning_of_day() == Time.now.beginning_of_day()
      user = User.find_by_phone_number(self.phone_number)
      if user
        #SEND GCM
      else
        #SEND SMS
      end
    end
  end

end
