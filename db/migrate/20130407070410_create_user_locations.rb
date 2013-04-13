class CreateUserLocations < ActiveRecord::Migration
  def change
    create_table :user_locations do |t|
      t.integer :user_id, null: false
      t.decimal :lat, precision: 10, scale: 8
      t.decimal :lng, precision: 11, scale: 8
      t.datetime :sent_at

      t.timestamps
    end

    add_index :user_locations, :user_id
  end
end
