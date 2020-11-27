namespace :data do
  require Rails.root.join 'lib/helpers/task_helpers'
  include TaskHelpers

  desc 'Import Music Folders'
  task update: :environment do
    clear_deleted_folders
    MusicFolder.find_each do |music_folder|
      update_folder_path music_folder
      update_folder_dates music_folder
    end
    import_folders
    import_subfolders
    update_music_folders_year
    update_music_folders_formatted_name
    update_music_folders_data_url
    update_audio_files_data_url
  end

  desc 'Clear database'
  task clear: :environment do
    ActiveRecord::Base.connection.execute "DELETE FROM #{MusicFolder.table_name} WHERE deleted_at IS NOT NULL"
    ActiveRecord::Base.connection.execute "DELETE FROM #{Image.table_name} WHERE deleted_at IS NOT NULL"
    ActiveRecord::Base.connection.execute "DELETE FROM #{AudioFile.table_name} WHERE deleted_at IS NOT NULL"
    ActiveRecord::Base.connection.execute "DELETE FROM #{M3uFile.table_name} WHERE deleted_at IS NOT NULL"
  end
end
