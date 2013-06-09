class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :event_user_id

      t.timestamps
    end
  end
end
