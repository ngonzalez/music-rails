class CreateAudioFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :audio_files do |t|
      t.integer :music_folder_id, null: false
      t.string :name, null: false
      t.string :format_info, null: false
      t.string :artist
      t.string :title
      t.string :album
      t.string :genre
      t.string :year
      t.integer :bitrate
      t.integer :channels
      t.integer :length_in_seconds
      t.integer :sample_rate
      t.datetime :created_at
      t.datetime :updated_at
      t.string :file_uid
      t.string :file_name
      t.datetime :deleted_at
      t.string :data_url
      t.index [:data_url], name: :index_audio_files_on_data_url, unique: true
      t.index [:music_folder_id], name: :index_audio_files_on_music_folder_id
    end
  end
end
