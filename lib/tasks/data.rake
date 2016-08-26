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
          ActiveRecord::Base.transaction do
            begin
              ImportWorker.new(name: path.split("/").last, folder: folder, path: path, source: source).perform
            rescue Exception => e
              raise ActiveRecord::Rollback
            end
          end
          bar.increment!
        end
      end
    end
    FOLDERS_WITH_LABELS.each do |folder|
      LABELS.each do |label_name|
        ALLOWED_SOURCES.each do |source|
          Dir["#{BASE_PATH}/#{folder}/#{label_name.gsub(" ", "_")}/#{source}/**"].each do |path|
            ActiveRecord::Base.transaction do
              begin
                ImportWorker.new(name: path.split("/").last, folder: folder, path: path, source: source, label_name: label_name).perform
              rescue Exception => e
                raise ActiveRecord::Rollback
              end
            end
            bar.increment!
          end
        end
      end
    end
  end

  desc "check sfv"
  task check_sfv: :environment do
    Release.where(last_verified_at: nil).select{|release| !release.details.has_key?(:sfv) }.select{|release| release.sfv_files.where(source: nil).any? }.each{|release| ImportWorker.new(name: release.name).check_sfv }
    Release.where(srrdb_last_verified_at: nil).decorate.select(&:scene?).select{|release| !release.details[:srrdb_sfv_error] && !release.details.has_key?(:srrdb_sfv) }.select{|release| !release.name.match(EXCEPT_GRPS) && release.sfv_files.where(source: 'srrDB').none? }.each{|release| ImportWorker.new(name: release.name).import_srrdb_sfv }
    Release.where(srrdb_last_verified_at: nil).decorate.select(&:scene?).select{|release| !release.details[:srrdb_sfv_error] && !release.details.has_key?(:srrdb_sfv) }.select{|release| !release.name.match(EXCEPT_GRPS) && release.sfv_files.where(source: 'srrDB').any? }.each{|release| ImportWorker.new(name: release.name).check_sfv 'srrDB' }
  end

  desc "set details"
  task set_details: :environment do
    release_set_details
  end

end