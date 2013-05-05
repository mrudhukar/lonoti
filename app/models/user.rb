class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :devise_id, :phone_number, :registration_id

  has_many :user_locations, dependent: :destroy
  has_many :events, dependent: :destroy, class_name: "AbstractEvent"
  has_many :time_events, dependent: :destroy, class_name: "Event::TimeBased"
  has_many :location_events, dependent: :destroy, class_name: "Event::LocationBased"

  before_save :ensure_authentication_token

  validates :registration_id, presence: true
end
