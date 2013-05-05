class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.belongs_to :user
      t.string :title
      t.text :message
      t.integer :status, default: AbstractEvent::State::ACTIVE
      t.string :type

      t.datetime :trigger_time
      t.boolean :send_location, default: false
      t.string :repeats_on_week
      
      t.decimal :lat, precision: 10, scale: 8
      t.decimal :lng, precision: 11, scale: 8
      t.text :address
      t.integer :distance_from_address

      t.timestamps
    end

    add_column :users, :registration_id, :string
  end
end
