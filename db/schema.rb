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

ActiveRecord::Schema.define(version: 20171118103631) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "images", id: :serial, force: :cascade do |t|
    t.integer "release_id", null: false
    t.string "file_uid", null: false
    t.string "file_name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string "thumb_uid"
    t.string "thumb_high_uid"
    t.string "type"
    t.index ["release_id"], name: "index_images_on_release_id"
  end

  create_table "m3u_files", id: :serial, force: :cascade do |t|
    t.integer "release_id", null: false
    t.string "file_uid", null: false
    t.string "file_name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string "source"
    t.index ["release_id"], name: "index_m3u_files_on_release_id"
  end

  create_table "releases", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "folder"
    t.datetime "last_verified_at"
    t.text "details"
    t.string "formatted_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string "subfolder"
    t.string "year"
    t.string "format_name"
    t.string "source"
    t.datetime "srrdb_last_verified_at"
    t.datetime "folder_created_at"
    t.datetime "folder_updated_at"
    t.string "data_url"
    t.index ["data_url"], name: "index_releases_on_data_url", unique: true
    t.index ["name"], name: "index_releases_on_name", unique: true
  end

  create_table "sfv_files", id: :serial, force: :cascade do |t|
    t.integer "release_id", null: false
    t.string "file_uid", null: false
    t.string "file_name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string "source"
    t.index ["release_id"], name: "index_sfv_files_on_release_id"
  end

  create_table "tracks", id: :serial, force: :cascade do |t|
    t.integer "release_id", null: false
    t.string "name", null: false
    t.string "format_info", null: false
    t.string "artist"
    t.string "title"
    t.string "album"
    t.string "genre"
    t.string "year"
    t.integer "bitrate"
    t.integer "channels"
    t.integer "length"
    t.integer "sample_rate"
    t.string "format_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "file_uid"
    t.string "file_name"
    t.string "process_id"
    t.string "number"
    t.datetime "deleted_at"
    t.index ["format_name"], name: "index_tracks_on_format_name"
    t.index ["release_id"], name: "index_tracks_on_release_id"
  end

  create_table "uploads", id: :serial, force: :cascade do |t|
    t.string "file_uid", null: false
    t.string "file_name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
