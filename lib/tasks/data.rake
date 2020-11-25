namespace :data do
  require Rails.root.join 'lib/helpers/task_helpers'
  include TaskHelpers

  desc 'update'
  task update: :environment do
    clear_deleted_folders
    Folder.find_each do |folder|
      update_release_path release
      update_release_folder_dates release
    end
    import_folders
    import_subfolders
    update_releases_year
    update_releases_formatted_name
    update_releases_data_url
    unchecked_releases.each do |folder|
      check_sfv release
    end
  end

  desc 'clear'
  task clear: :environment do
    RedisDb.client.flushall
    ActiveRecord::Base.connection.execute "DELETE FROM #{Folder.table_name} WHERE deleted_at IS NOT NULL"
    ActiveRecord::Base.connection.execute "DELETE FROM #{Image.table_name} WHERE deleted_at IS NOT NULL"
    ActiveRecord::Base.connection.execute "DELETE FROM #{AudioFile.table_name} WHERE deleted_at IS NOT NULL"
    ActiveRecord::Base.connection.execute "DELETE FROM #{SfvFile.table_name} WHERE deleted_at IS NOT NULL"
    ActiveRecord::Base.connection.execute "DELETE FROM #{M3uFile.table_name} WHERE deleted_at IS NOT NULL"
    AudioFile.update_all file_uid: nil, file_name: nil
    FileUtils.rm_rf Rails.root + 'public/system/dragonfly/tracks'
    FileUtils.rm_rf '/tmp/dragonfly'
  end
end
