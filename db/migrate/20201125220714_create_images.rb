class CreateImages < ActiveRecord::Migration[6.0]
  def change
    create_table :images do |t|
      t.integer :music_folder_id, null: false
      t.string :file_uid, null: false
      t.string :file_name, null: false
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :deleted_at
      t.string :thumb_uid
      t.string :thumb_high_uid
      t.string :type
      t.index [:music_folder_id], name: :index_images_on_music_folder_id
    end
  end
end
