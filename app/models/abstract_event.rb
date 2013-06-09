class AbstractEvent < ActiveRecord::Base
  self.table_name = 'events'
  module State
    ACTIVE = 0
    INACTIVE = 1
    ARCHIVED = 2
  end

  attr_accessible :title, :message

  belongs_to :user
  has_many :event_users, dependent: :destroy, foreign_key: :event_id

  validates :title, :message, :user, :status, :type, presence: true
  validates :status, inclusion: {in: [State::ACTIVE, State::INACTIVE, State::ARCHIVED] }

  default_scope where("events.status != ?", State::ARCHIVED)
  scope :active, where(status: State::ACTIVE)

  def update_and_build_event_users(friends)
    new_phone_numbers = friends.collect{|n| n[:phone_number]}

    self.event_users.each do |eu|
      unless new_phone_numbers.include?(eu.phone_number)
        eu.destroy
      end
    end

    friends.each do |neu|
      if eu = self.event_users.find_by_phone_number(neu[:phone_number])
        eu.update_attributes(neu)
      else
        eventuser = self.event_users.build(neu)
        eventuser.event = self
      end
    end
  end

end
