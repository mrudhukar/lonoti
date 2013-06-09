class Notification < ActiveRecord::Base
  #TODO Should we use acts as paranoid here for soft deletes?
  belongs_to :event_user
end
