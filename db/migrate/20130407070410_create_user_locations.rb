class CreateUserLocations < ActiveRecord::Migration
  def change
    create_table :user_locations do |t|
      t.integer :user_id, null: false
      t.float :lat
      t.float :lng
      t.datetime :sent_at

      t.timestamps
    end

    add_index :user_locations, :user_id
  end
end
