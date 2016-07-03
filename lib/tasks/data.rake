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

  desc "check sfv"
  task sfv: :environment do
    ["import_sfv", "check_sfv",
      "import_srrdb_sfv", "check_srrdb_sfv"].each do |name|
      Rake::Task["data:#{name}"].execute
    end
  end

  desc "import sfv"
  task import_sfv: :environment do
    Release.find_each do |release|
      next if release.sfv
      Dir[release.decorate.public_path + "/*.#{SFV_TYPE}"].each do |sfv_path|
        release.update! sfv: File.read(sfv_path), sfv_name: sfv_path.split("/").last
        sleep 0.01
      end
    end
  end

  desc "import srrdb sfv"
  task import_srrdb_sfv: :environment do
    Release.where("sfv_uid IS NOT NULL AND srrdb_sfv_uid IS NULL").each do |release|
      next if release.name.ends_with? release.decorate.year_from_name
      begin
        import_srrdb_sfv release
        sleep 5
      rescue SrrdbLimitReachedError => e
        Rails.logger.info "SRRDB: %s" % [ e.inspect ]
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

  desc "check nfo"
  task check_nfo: :environment do
    Release.find_each do |release|
      next if release.details[NFO_TYPE.to_sym]
      if !release.images.detect{|image| image.file_type == NFO_TYPE }
        release.details[NFO_TYPE.to_sym] = :not_found
        release.save!
      end
    end
  end

  desc "set details"
  task set_details: :environment do
    Track.where(number: nil).each do |track|
      track.update! number: format_number(track.name)
    end
    Release.where(formatted_name: nil).each do |release|
      release.update! formatted_name: format_name(release.name)
    end
    Release.where(year: nil).each do |release|
      next if release.tracks.empty?
      release.update! year: release.tracks[0].year.to_i
    end
    Release.where(year: "0").find_each do |release|
      year = release.decorate.year_from_name
      release.tracks.each{|track| track.update! year: year }
      release.update! year: year
    end
    Release.where(format_name: nil).each do |release|
      release.update! format_name: get_format_from_release_name(release) || format_track_format(release)
    end
    Release.includes(:tracks).where(tracks: { format_name: nil }).each do |release|
      release.tracks.update_all format_name: format_track_format(release)
    end
  end

end
