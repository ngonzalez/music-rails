
namespace "music" do

  desc "update data"
  task update: :environment do
    ["clear_data", "load_data"].each do |name|
      Rake::Task["music:#{name}"].execute
    end
  end

  desc "clear data"
  task clear_data: :environment do
    Release.find_each do |release|
      if !File.directory? [BASE_PATH, release.decorate.path].join("/")
        release.destroy
      end
    end
  end

  desc "set details"
  task set_details: :environment do
    def format_number name
      name.split("-").length > 2 ? name.split("-")[0] : name.split("_")[0]
    end
    def format_name name
      year = name.split("-").select{|item| item.match(/(\d{4})/) }.last
      name.gsub("_-_", "-").gsub("(", "").gsub(")", "").split("-").each_with_object([]){|string, array|
        next if array.include? year
        str = string.gsub("_", " ")
        next if str.blank?
        next if ["WEB", "VA", "WAV", "FLAC", "AIFF", "ALAC"].include?(str)
        next if ALLOWED_SOURCES.map(&:upcase).include?(str.upcase)
        array << str
      }.reject{|item| item == year }.join(" ")
    end
    def format_track_format release
      return if release.tracks.empty?
      case release.tracks[0].format
        when /FLAC/ then "FLAC"
        when /MPEG ADTS, layer III, v1, 192 kbps/ then "MP3-192CBR"
        when /MPEG ADTS, layer III, v1, 256 kbps/ then "MP3-256CBR"
        when /MPEG ADTS, layer III, v1, 320 kbps/ then "MP3-320CBR"
        when /MPEG ADTS, layer III|MPEG ADTS, layer II|Audio file with ID3/
          case release.tracks.map(&:bitrate).sum.to_f / release.tracks.length
            when 192.0 then "MP3-192CBR"
            when 256.0 then "MP3-256CBR"
            when 320.0 then "MP3-320CBR"
            else
              "MP3"
          end
        when /WAVE audio/ then "WAV"
        when /iTunes AAC/ then "iTunes AAC"
        when /MPEG v4/ then "MPEG4"
        when /clip art|BINARY|data/ then get_format_from_release_name(release) || "DATA"
      end
    end
    def get_format_from_release_name release
      case release.name
        when /\-FLAC\-/ then "FLAC"
        when /\-ALAC\-/ then "ALAC"
        when /\-WAV\-/ then "WAV"
        when /\-AIFF\-/ then "AIFF"
      end
    end
    # Set Track Numbers
    Track.where(number: nil).each do |track|
      track.update! number: format_number(track.name)
    end
    # Set Release Formatted Name
    Release.where(formatted_name: nil).each do |release|
      release.update! formatted_name: format_name(release.name)
    end
    # Set Release Year, Audio Format Name
    Release.where(year: nil).each do |release|
      next if release.tracks.empty?
      release.update! year: release.tracks[0].year.to_i
    end
    Release.where(year: "0").find_each do |release|
      year = release.name.split("-").select{|item| item.match(/(\d{4})/) }.last.to_i
      release.tracks.update_all year: year
      release.update! year: year
    end
    Release.where(format_name: nil).each do |release|
      release.update! format_name: get_format_from_release_name(release) || format_track_format(release)
    end
    Release.includes(:tracks).where(tracks: { format_name: nil }).each do |release|
      release.tracks.update_all format_name: format_track_format(release)
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

  desc "import sfv"
  task import_sfv: :environment do
    Release.find_each do |release|
      next if release.sfv
      Dir[[BASE_PATH, release.decorate.path].join("/") + "/*.#{SFV_TYPE}"].each do |sfv_path|
        release.update! sfv: File.read(sfv_path), sfv_name: sfv_path.split("/").last
        sleep 0.01
      end
    end
  end

  desc "import srrdb sfv"
  task import_srrdb_sfv: :environment do
    Release.find_each do |release|
      next if !release.name
      year = release.name.split("-").select{|item| item.match(/(\d{4})/) }.last
      next if !year
      next if release.name.ends_with? year
      if release.sfv && !release.srrdb_sfv
        next if release.details[:srrdb_sfv_error]
        url = ["http://www.srrdb.com/download/file"]
        url << release.name
        url << release.sfv_name
        puts url.join("/")
        response = Typhoeus.get url.join("/")
        if response.code != 200 || response.body.blank?
          release.details[:srrdb_sfv_error] = true
          release.save!
          next
        end
        begin
          content = response.body.force_encoding('Windows-1252').encode('UTF-8')
          raise if content == "You've reached the daily limit."
          f = Tempfile.new ; f.write(content) ; f.rewind
          release.update! srrdb_sfv: f
        rescue
          binding.pry
          raise
        end
        puts "------------------------------------"
        puts File.read(release.srrdb_sfv.path).inspect
        puts "------------------------------------"
        f.unlink
        sleep 5
      end
    end
  end

  desc "check sfv"
  task check_sfv: :environment do
    Release.find_each do |release|
      if release.last_verified_at
        next
      elsif release.details[:sfv]
        next
      elsif !release.sfv
        next
      end
      cmd = "cfv" # cfv 1.18.3
      path = [BASE_PATH, release.decorate.path].join("/")
      details = case Dir.chdir(path) { %x[#{cmd} -f #{release.sfv.path}] }
        when /badcrc/ then "badcrc"
        when /chksum file errors/ then "chksum file errors"
        when /not found/ then "missing files"
        when /No such file/ then "file not found"
      end
      if details
        release.details[:sfv] = details
        release.save!
      else
        release.update! last_verified_at: Time.now
      end
    end
  end

  desc "check srrdb sfv"
  task check_srrdb_sfv: :environment do
    Release.find_each do |release|
      if release.srrdb_last_verified_at
        next
      elsif release.details[:srrdb_sfv]
        next
      elsif !release.srrdb_sfv
        next
      end
      cmd = "cfv" # cfv 1.18.3
      path = [BASE_PATH, release.decorate.path].join("/")
      details = case Dir.chdir(path) { %x[#{cmd} -f #{release.srrdb_sfv.path}] }
        when /badcrc/ then "badcrc"
        when /chksum file errors/ then "chksum file errors"
        when /not found/ then "missing files"
        when /No such file/ then "file not found"
      end
      if details
        release.details[:srrdb_sfv] = details
        release.save!
      else
        release.update! srrdb_last_verified_at: Time.now
      end
    end
  end

  desc "check nfo"
  task check_nfo: :environment do
    Release.find_each do |release|
      next if release.details[:no_nfo]
      if !release.images.detect{|image| image.file_type == NFO_TYPE }
        release.details[:no_nfo] = true
        release.save!
      end
    end
  end

end
