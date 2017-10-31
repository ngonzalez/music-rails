namespace 'data' do

  require Rails.root.join 'lib/helpers/task_helpers'
  include TaskHelpers

  require Rails.root.join 'lib/helpers/format_helpers'
  include FormatHelpers

  require Rails.root.join 'lib/helpers/sfv_helpers'
  include SfvHelpers

  desc 'update data'
  task update: :environment do
    ['update_data', 'load_data', 'check_sfv',
      'check_srrdb_sfv', 'set_details'].each do |name|
      Rake::Task["data:#{name}"].execute
    end
  end

  desc 'update data'
  task update_data: :environment do
    require 'progress_bar'
    bar = ProgressBar.new Release.count
    Release.find_each do |release|
      update_release release
      bar.increment!
    end
  end

  desc 'load data'
  task load_data: :environment do
    import_folders
    import_subfolders
  end

  desc 'set details'
  task set_details: :environment do
    release_set_details
  end

  desc 'check sfv'
  task check_sfv: :environment do
    unchecked_releases.each do |release|
      check_sfv release
    end
  end

  desc 'check srrdb sfv'
  task check_srrdb_sfv: :environment do
    require Rails.root.join "lib/helpers/scene_helpers"
    include SceneHelpers
    import_srrdb_sfv
    unchecked_releases(:srrdb).each do |release|
      check_sfv release, 'srrDB'
    end
  end

  desc 'clear'
  task clear: :environment do
    NfoFile.select { |nfo_file| !nfo_file.file_exists? }.each &:destroy
    M3uFile.select { |m3u_file| !m3u_file.file_exists? }.each &:destroy
    SfvFile.select { |sfv_file| !sfv_file.file_exists? }.each &:destroy
    Track.update_all file_uid: nil, file_name: nil, process_id: nil
    FileUtils.rm_rf Rails.root + 'public/system/dragonfly/tracks'
    FileUtils.rm_rf '/tmp/dragonfly'
    Rails.cache.clear
  end

end