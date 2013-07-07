# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130609174433) do

  create_table "event_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.string   "phone_number"
    t.string   "email"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "message"
    t.integer  "status",                                               :default => 0
    t.string   "type"
    t.datetime "trigger_time"
    t.boolean  "send_location",                                        :default => false
    t.string   "repeats_on_week"
    t.decimal  "lat",                   :precision => 10, :scale => 8
    t.decimal  "lng",                   :precision => 11, :scale => 8
    t.text     "address"
    t.integer  "distance_from_address"
    t.datetime "created_at",                                                              :null => false
    t.datetime "updated_at",                                                              :null => false
  end

  create_table "gcm_devices", :force => true do |t|
    t.string   "registration_id",    :null => false
    t.datetime "last_registered_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "gcm_devices", ["registration_id"], :name => "index_gcm_devices_on_registration_id", :unique => true

  create_table "gcm_notifications", :force => true do |t|
    t.integer  "device_id",        :null => false
    t.string   "collapse_key"
    t.text     "data"
    t.boolean  "delay_while_idle"
    t.datetime "sent_at"
    t.integer  "time_to_live"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "gcm_notifications", ["device_id"], :name => "index_gcm_notifications_on_device_id"

  create_table "notifications", :force => true do |t|
    t.integer  "event_user_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "user_locations", :force => true do |t|
    t.integer  "user_id",                                   :null => false
    t.decimal  "lat",        :precision => 10, :scale => 8
    t.decimal  "lng",        :precision => 11, :scale => 8
    t.datetime "sent_at"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.text     "address"
  end

  add_index "user_locations", ["user_id"], :name => "index_user_locations_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "devise_id"
    t.string   "phone_number"
    t.string   "registration_id"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
