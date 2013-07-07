class EventUser < ActiveRecord::Base
  attr_accessible :email, :phone_number

  belongs_to :event, class_name: "AbstractEvent", foreign_key: :event_id
  belongs_to :user

  has_many :notifications, dependent: :destroy

  validates :event, :phone_number, presence: true
  validates :phone_number, uniqueness: {scope: :event_id }
  validates :user_id, uniqueness: {scope: :event_id }, allow_nil: true

  def send_message_notification(loc = nil)
    event = self.event
    recent_notification = self.notifications.last
    return if recent_notification && recent_notification.created_at.beginning_of_day() == Time.now.beginning_of_day()

    user = User.find_by_phone_number(self.phone_number)
    if user
      create_gcm_notification(user.registration_id, "updates_available", {event: 4})
    else
      #SEND SMS
    end
  end

  def send_location_notification
    create_gcm_notification(self.event.owner.registration_id, "updates_available", {event: 4})
  end

  private

  def create_gcm_notification(reg_id, collapse_key, data)
    device = Gcm::Device.find_or_create_by_registration_id(reg_id)
    notification = Gcm::Notification.new
    notification.device = device
    notification.collapse_key = "updates_available"
    notification.delay_while_idle = true
    notification.data = {:registration_ids => [reg_id], :data => data}
    notification.save
  end

end