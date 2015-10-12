
namespace "music" do

  desc "update data"
  task update: :environment do
    [ "load_data", "import_images", "import_nfo",
      "check_releases", "set_format_names",
      "set_formatted_names", "set_track_numbers"].each do |name|
      Rake::Task["music:#{name}"].execute
    end
  end

  desc "set track numberss"
  task set_track_numbers: :environment do
    def format_number name
      name.split("-").length > 2 ? name.split("-")[0] : name.split("_")[0]
    end
    Track.where(number: nil).each do |track|
      track.update! number: format_number(track.name)
    end
  end

  desc "set formatted releases names"
  task set_formatted_names: :environment do
    def format_name name
      year = name.match(/-(\d+)-/).to_s.gsub("-", "")
      name.gsub("_-_", "-").split("-").each_with_object([]){|string, array|
        next if array.include? year
        str = string.gsub("_", " ")
        next if str.blank?
        next if ["WEB", "VA", "WAV", "FLAC", "AIFF", "ALAC"].include?(str)
        array << str
      }.join " "
    end
    Release.where(formatted_name: nil).each do |release|
      release.update! formatted_name: format_name(release.name)
    end
  end

  desc "set encoding format names"
  task set_format_names: :environment do
    def format_track_format track
      case track.format
        when /FLAC/ then "FLAC"
        when /MPEG ADTS, layer III, v1, 192 kbps/ then "MP3-192CBR"
        when /MPEG ADTS, layer III, v1, 256 kbps/ then "MP3-256CBR"
        when /MPEG ADTS, layer III, v1, 320 kbps/ then "MP3-320CBR"
        when /MPEG ADTS, layer III|MPEG ADTS, layer II|Audio file with ID3/
          case track.release.tracks.map(&:bitrate).sum.to_f / track.release.tracks.length
            when 192.0 then "MP3-192CBR"
            when 256.0 then "MP3-256CBR"
            when 320.0 then "MP3-320CBR"
            else
              "MP3"
          end
        when /WAVE audio/ then "WAV"
        when /iTunes AAC/ then "iTunes AAC"
        when /MPEG v4/ then "MPEG4"
        when /clip art|BINARY|data/ then "DATA"
      end
    end
    def get_format_from_release_name release
      case release.name
        when /\-FLAC\-/ then "FLAC"
        when /\-ALAC\-/ then "ALAC"
        when /\-WAV\-/ then "WAV"
      end
    end
    Release.find_each do |release|
      format_name = get_format_from_release_name release
      release.tracks.where(format_name: nil).each do |track|
        format_name = format_track_format(track) if !format_name
        track.update format_name: format_name
      end
    end
  end

  desc "load data"
  task load_data: :environment do

    require 'progress_bar'

    require 'taglib'

    t1 = Time.now ; count = 0

    main_folders = ["dnb","hc","other"]
    allowed_formats = ["mp3","mp4","m4a","flac","wav", "aiff"]

    main_folders.each do |folder|

      @directories = Dir["#{BASE_PATH}/#{folder}/**"]

      puts "Update folder: #{BASE_PATH}/#{folder}/"

      bar = ProgressBar.new @directories.count

      @directories.each do |path|

        bar.increment!

        release_name = path.split("/").last

        next if Release.where(name: release_name, folder: folder).any?

        ActiveRecord::Base.transaction do

          begin

            release = Release.find_by(name: release_name, folder: folder)

            release = Release.create!(name: release_name, folder: folder) if !release

            allowed_formats.each do |format|
              Dir["#{path}/*.#{format}"].each do |file|

                track_name = file.split("/").last

                track = release.tracks.find_by name: track_name

                if !track

                  track = release.tracks.new(name: track_name)

                  track.format = `file -b #{Shellwords.escape(file)}`.force_encoding('Windows-1252').encode('UTF-8').gsub("\n", "").strip

                  TagLib::FileRef.open(file) do |infos|

                    tag = infos.tag
                    ["artist", "title", "album", "genre", "year"].each do |name|
                      track.send("#{name}=", tag.send(name))
                    end

                    audio_properties = infos.audio_properties
                    ["bitrate", "channels", "length", "sample_rate"].each do |name|
                      track.send("#{name}=", audio_properties.send(name))
                    end

                  end

                  track.save!

                  count += 1

                end

              end
            end

          rescue Exception => e

            puts e.inspect

            puts "FAILED: %s" % [ release_name ]

            raise ActiveRecord::Rollback

          end

        end

      end

    end

    puts "Updated %s records in %s" % [count, (Time.now - t1)]

  end

  desc "check releases"
  task check_releases: :environment do
    cmd = "cfv" # cfv 1.18.3
    Release.where(last_verified_at: nil).order("id desc").each do |release|
      release = release.decorate
      next if !release.details.empty? && release.details.has_key?("sfv")
      path = [PUBLIC_PATH, release.path].join "/"
      if Dir["#{path}/*.sfv"].empty? # No SFV
        release.update details: { "sfv" => "not found" }
        next
      end
      details = case Dir.chdir(path) { %x[#{cmd}] }
        when /badcrc/ then "badcrc"
        when /chksum file errors/ then "chksum file errors"
        when /not found/ then "missing files"
      end
      if details
        release.update! details: { "sfv" => details }
      else
        release.update! last_verified_at: Time.now
      end
    end
  end

  desc "import images"
  task import_images: :environment do
    allowed_formats = ["jpg", "jpeg", "gif", "png", "tiff", "bmp"]
    Release.where(last_verified_at: nil, details: nil).each do |release|
      path = [PUBLIC_PATH, release.decorate.path].join "/"
      allowed_formats.each do |format|
        Dir["#{path}/*.#{format}"].each do |path|
          file_name = path.split("/").last
          next if file_name =~ /.log./
          next if release.images.where(file_name: file_name).any?
          release.images.create! file: File.open(path)
        end
      end
    end
  end

  desc "import NFO"
  task import_nfo: :environment do
    temp_file = "/tmp/#{Time.now.to_i}"
    font = Rails.root + "app/assets/fonts/ProFont/ProFontWindows.ttf"
    Release.where(last_verified_at: nil, details: nil).includes(:images).order("id desc").each do |release|
      begin
        next if release.images.select{|item| item.file_type == "nfo" }.any?
        Dir[PUBLIC_PATH + release.decorate.path + "/*.nfo"].each do |file|
          File.open(temp_file, 'w:UTF-8') do |f|
            File.open(file).each_line do |line|
              # Remove ^M when copy files from Windows
              # https://en.wikipedia.org/wiki/Code_page_437
              f.write line.gsub("\C-M", "").force_encoding("CP437")
            end
          end
          content = Dragonfly.app.generate(:text, "@#{temp_file}", { 'font': font.to_s, 'format': 'svg' })
          release.images.create! file: content, file_type: 'nfo'
        end
      rescue
        next
      end
    end
    FileUtils.rm(temp_file) if File.exists?(temp_file)
  end

end