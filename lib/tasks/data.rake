namespace :data do
  require Rails.root.join 'lib/helpers/task_helpers'
  include TaskHelpers

  desc 'update'
  task update: :environment do
    clear_deleted_folders
    update_releases
    import_folders
    import_subfolders
    release_set_details
    release_check_sfv
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
    Rails.cache.clear
  end
end
