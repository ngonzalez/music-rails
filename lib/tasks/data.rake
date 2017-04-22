namespace "data" do

  require Rails.root.join "lib/task_helpers"
  include TaskHelpers

  desc "update data"
  task update: :environment do
    ["clear_data", "load_data", "check_sfv", "set_details"].each do |name|
      Rake::Task["data:#{name}"].execute
    end
  end

  desc "clear data"
  task clear_data: :environment do
    Release.find_each do |release|
      if !File.directory? release.decorate.public_path
        release.destroy
      end
    end
  end

  desc "load data"
  task load_data: :environment do
    require 'progress_bar'
    bar = ProgressBar.new Release.count
    FOLDERS.each do |folder|
      ALLOWED_SOURCES.each do |source|
        Dir["#{BASE_PATH}/#{folder}/#{source}/**"].each do |path|
          name = path.split("/").last
          next if EXCEPT_RLS.include?(name)
          ImportWorker.new(path: path, name: name, folder: folder, source: source).perform
          bar.increment!
        end
      end
    end
    FOLDERS_WITH_SUBFOLDERS.each do |parent_folder|
      Dir["#{BASE_PATH}/#{parent_folder}/**"].each do |folder|
        ALLOWED_SOURCES.each do |source|
          Dir["#{folder}/#{source}/**"].each do |path|
            name = path.split("/").last
            next if EXCEPT_RLS.include?(name)
            subfolder_name = folder.split("/").last
            folder_name = folder.gsub("#{BASE_PATH}/", "").gsub("/#{subfolder_name}", "")
            ImportWorker.new(path: path, name: name, folder: folder_name, subfolder: subfolder_name, source: source).perform
            bar.increment!
          end
        end
      end
    end
  end

  desc "check sfv"
  task check_sfv: :environment do
    Release.joins(:sfv_files).merge(SfvFile.local).where(last_verified_at: nil).select{|release| !release.details.has_key?(:sfv) }.each do |release|
      check_sfv release
    end
    Release.joins(:sfv_files).merge(SfvFile.srrdb).where(srrdb_last_verified_at: nil).select{|release| !release.details.has_key?(:srrdb_sfv) }.each do |release|
      check_sfv release, "srrDB"
    end
  end

  desc "set details"
  task set_details: :environment do
    release_set_details
  end

end