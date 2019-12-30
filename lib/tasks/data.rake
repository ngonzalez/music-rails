namespace :data do
  require Rails.root.join 'lib/helpers/task_helpers'
  include TaskHelpers

  desc 'update'
  task update: :environment do
    clear_deleted_folders
    Release.find_each do |release|
      update_release_path release
      update_release_folder_dates release
    end
    import_folders
    import_subfolders
    update_releases_year
    update_releases_formatted_name
    update_releases_data_url
    unchecked_releases.each do |release|
      check_sfv release
    end
  end

  desc 'clear'
  task clear: :environment do
    ActiveRecord::Base.connection.execute "DELETE FROM #{Release.table_name} WHERE deleted_at IS NOT NULL"
    ActiveRecord::Base.connection.execute "DELETE FROM #{Image.table_name} WHERE deleted_at IS NOT NULL"
    ActiveRecord::Base.connection.execute "DELETE FROM #{Track.table_name} WHERE deleted_at IS NOT NULL"
    ActiveRecord::Base.connection.execute "DELETE FROM #{SfvFile.table_name} WHERE deleted_at IS NOT NULL"
    ActiveRecord::Base.connection.execute "DELETE FROM #{M3uFile.table_name} WHERE deleted_at IS NOT NULL"
    Track.update_all file_uid: nil, file_name: nil
    FileUtils.rm_rf Rails.root + 'public/system/dragonfly/tracks'
    FileUtils.rm_rf '/tmp/dragonfly'
    FileUtils.rm_rf '/tmp/rack-cache'
    Rails.cache.clear
  end
end
