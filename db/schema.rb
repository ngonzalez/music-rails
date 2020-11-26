# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_26_142911) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "audio_files", force: :cascade do |t|
    t.integer "music_folder_id", null: false
    t.string "name", null: false
    t.string "format_info", null: false
    t.string "artist"
    t.string "title"
    t.string "album"
    t.string "genre"
    t.string "year"
    t.integer "bitrate"
    t.integer "channels"
    t.integer "length_in_seconds"
    t.integer "sample_rate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "file_uid"
    t.string "file_name"
    t.datetime "deleted_at"
    t.string "data_url"
    t.index ["data_url"], name: "index_audio_files_on_data_url", unique: true
    t.index ["music_folder_id"], name: "index_audio_files_on_music_folder_id"
  end

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

  create_table "images", force: :cascade do |t|
    t.integer "music_folder_id", null: false
    t.string "file_uid", null: false
    t.string "file_name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string "thumb_uid"
    t.string "thumb_high_uid"
    t.string "type"
    t.index ["music_folder_id"], name: "index_images_on_music_folder_id"
  end

  create_table "m3u_files", force: :cascade do |t|
    t.integer "music_folder_id", null: false
    t.string "file_uid", null: false
    t.string "file_name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string "source"
    t.string "base_path"
    t.index ["music_folder_id"], name: "index_m3u_files_on_music_folder_id"
  end

  create_table "music_folders", force: :cascade do |t|
    t.string "name", null: false
    t.string "folder"
    t.text "details"
    t.string "formatted_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string "subfolder"
    t.string "year"
    t.string "source"
    t.datetime "folder_created_at"
    t.datetime "folder_updated_at"
    t.string "data_url"
    t.index ["data_url"], name: "index_music_folders_on_data_url", unique: true
    t.index ["name"], name: "index_music_folders_on_name", unique: true
  end

  create_table "versions", force: :cascade do |t|
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
