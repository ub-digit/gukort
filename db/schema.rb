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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180516113505) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "messages", force: :cascade do |t|
    t.text "raw_message"
    t.string "message_source"
    t.string "message_type"
    t.string "message_category"
    t.string "categorycode"
    t.string "personalnumber"
    t.string "old_personalnumber"
    t.string "cardnumber"
    t.string "pincode"
    t.string "valid_info"
    t.string "valid_to"
    t.string "invalid_reason"
    t.string "surname"
    t.string "firstname"
    t.string "co"
    t.string "address"
    t.string "zipcode"
    t.string "city"
    t.string "country"
    t.string "temp_co"
    t.string "temp_address"
    t.string "temp_zipcode"
    t.string "temp_city"
    t.string "temp_country"
    t.string "temp_from"
    t.string "temp_to"
    t.string "phone"
    t.string "email"
    t.string "userid"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "originated_at"
    t.string "exit_message"
    t.string "update_message"
  end

end
