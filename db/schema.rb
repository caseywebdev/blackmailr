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

ActiveRecord::Schema.define(:version => 20120426001808) do

  create_table "blackmail", :force => true do |t|
    t.integer  "user_id",      :null => false
    t.string   "title",        :null => false
    t.string   "description",  :null => false
    t.string   "victim_name",  :null => false
    t.string   "victim_email", :null => false
    t.datetime "expired_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "victim_token"
    t.binary   "image"
  end

  add_index "blackmail", ["user_id"], :name => "index_blackmail_on_user_id"

  create_table "demands", :force => true do |t|
    t.integer  "blackmail_id",                    :null => false
    t.string   "description"
    t.boolean  "completed",    :default => false, :null => false
    t.datetime "updated_at"
  end

  add_index "demands", ["blackmail_id"], :name => "index_demands_on_blackmail_id"

  create_table "messages", :force => true do |t|
    t.integer  "blackmail_id",                    :null => false
    t.text     "content"
    t.boolean  "from_victim",  :default => false, :null => false
    t.datetime "created_at"
  end

  add_index "messages", ["blackmail_id"], :name => "index_messages_on_blackmail_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest", :null => false
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "remember_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
