class CreateM3uFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :m3u_files do |t|
      t.integer :music_folder_id, null: false
      t.string :file_uid, null: false
      t.string :file_name, null: false
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :deleted_at
      t.string :source
      t.string :base_path
      t.index [:music_folder_id], name: :index_m3u_files_on_music_folder_id
    end
  end
end
