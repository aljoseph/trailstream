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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160326000118) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "hikes", force: :cascade do |t|
    t.string  "hike_name"
    t.float   "roundtrip_distance"
    t.float   "elevation_gain"
    t.float   "highest_point"
    t.string  "trailhead_coordinates"
    t.string  "required_passes"
    t.string  "image_url"
    t.string  "trail_attributes"
    t.string  "region"
    t.float   "miles_from_seattle"
    t.integer "minutes_from_seattle"
    t.string  "hike_url"
    t.text    "summary"
    t.string  "hike_id"
    t.string  "instagram_location_id"
    t.string  "instagram_tag"
    t.integer "transit_time"
  end

end
