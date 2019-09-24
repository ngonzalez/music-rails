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
    NfoFile.select { |nfo_file| !nfo_file.file_exists? }.each &:destroy
    M3uFile.select { |m3u_file| !m3u_file.file_exists? }.each &:destroy
    SfvFile.select { |sfv_file| !sfv_file.file_exists? }.each &:destroy
    Track.update_all file_uid: nil, file_name: nil
    FileUtils.rm_rf Rails.root + 'public/system/dragonfly/tracks'
    FileUtils.rm_rf '/tmp/dragonfly'
    Rails.cache.clear
  end
end
