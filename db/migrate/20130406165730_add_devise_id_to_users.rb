class AddDeviseIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :devise_id, :string
  end
end
