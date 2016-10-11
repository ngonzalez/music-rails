class CreateM3uFiles < ActiveRecord::Migration
  def change
    create_table :m3u_files do |t|
      t.integer  "release_id",     null: false
      t.string   "file_uid",       null: false
      t.string   "file_name",      null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
      t.string   "source"
    end
  end
end
