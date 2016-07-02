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

ActiveRecord::Schema.define(version: 20160702141851) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "images", force: :cascade do |t|
    t.integer  "release_id", null: false
    t.string   "file_uid",   null: false
    t.string   "file_name",  null: false
    t.string   "file_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "releases", force: :cascade do |t|
    t.string   "name",                   null: false
    t.string   "folder"
    t.datetime "last_verified_at"
    t.text     "details"
    t.string   "formatted_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "label_name"
    t.string   "year"
    t.string   "format_name"
    t.string   "source"
    t.string   "srrdb_sfv_uid"
    t.string   "sfv_uid"
    t.string   "sfv_name"
    t.datetime "srrdb_last_verified_at"
  end

  create_table "tracks", force: :cascade do |t|
    t.integer  "release_id",  null: false
    t.string   "name",        null: false
    t.string   "format",      null: false
    t.string   "artist"
    t.string   "title"
    t.string   "album"
    t.string   "genre"
    t.string   "year"
    t.integer  "bitrate"
    t.integer  "channels"
    t.integer  "length"
    t.integer  "sample_rate"
    t.string   "format_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_uid"
    t.string   "file_name"
    t.string   "process_id"
    t.string   "number"
    t.datetime "deleted_at"
  end

  add_index "tracks", ["format_name"], name: "index_tracks_on_format_name", using: :btree

  create_table "uploads", force: :cascade do |t|
    t.string   "file_uid",   null: false
    t.string   "file_name",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
