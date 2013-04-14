class AddAddressToUserLocation < ActiveRecord::Migration
  def change
    add_column :user_locations, :address, :text
  end
end
