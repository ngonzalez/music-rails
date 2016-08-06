namespace "data" do

  require Rails.root.join "lib/task_helpers"
  include TaskHelpers

  desc "update data"
  task update: :environment do
    ["sync", "sfv", "set_details"].each do |name|
      Rake::Task["data:#{name}"].execute
    end
  end

  desc "sync data"
  task sync: :environment do
    ["clear_data", "load_data"].each do |name|
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

    ["dnb","hc","other"].each do |folder|
      ALLOWED_SOURCES.each do |source|
        Dir["#{BASE_PATH}/#{folder}/#{source}/**"].each do |path|
          ImportWorker.new.perform folder: folder, path: path, source: source
          bar.increment!
        end
      end
    end

    Dir["#{BASE_PATH}/backup/**"].each do |label_path|
      label_name = label_path.split("/").last
      ALLOWED_SOURCES.each do |source|
        Dir["#{BASE_PATH}/backup/#{label_name}/#{source}/**"].each do |path|
          ImportWorker.new.perform folder: "backup", path: path, source: source, label_name: label_name
          bar.increment!
        end
      end
    end
  end

  desc "set details"
  task set_details: :environment do
    release_set_details
  end

  desc "check sfv"
  task sfv: :environment do
    [
      "import_sfv", "check_sfv",
      "import_srrdb_sfv", "check_srrdb_sfv"
    ].each do |name|
      Rake::Task["data:#{name}"].execute
    end
  end

  desc "import sfv"
  task import_sfv: :environment do
    Release.where(sfv_uid: nil).each do |release|
      Dir[release.decorate.public_path + "/*.#{SFV_TYPE}"].each do |sfv_path|
        release.update! sfv: File.read(sfv_path), sfv_name: sfv_path.split("/").last
        sleep 0.01
      end
    end
  end

  desc "import srrdb sfv"
  task import_srrdb_sfv: :environment do
    Release.where(srrdb_sfv_uid: nil).decorate.select(&:scene?).each do |release|
      begin
        import_srrdb_sfv release
      rescue SrrdbLimitReachedError => e
        Rails.logger.info "SRRDB: %s" % [ e.message ]
        break
      end
    end
  end

  desc "check sfv"
  task check_sfv: :environment do
    Release.find_each do |release|
      check_sfv release, :last_verified_at, :sfv
    end
  end

  desc "check srrdb sfv"
  task check_srrdb_sfv: :environment do
    Release.find_each do |release|
      check_sfv release, :srrdb_last_verified_at, :srrdb_sfv
    end
  end

end
