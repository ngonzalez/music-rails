
namespace "music" do

  desc "update data"
  task update: :environment do
    [ "load_data", "import_images", "import_nfo",
      "check_releases", "clean_images",
      "set_format_names", "set_formatted_names"].each do |name|
      Rake::Task["music:#{name}"].execute
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
        next if ["WEB", "VA"].include?(str)
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

          rescue

            puts "FAILED: %s" % [ release_name ]

            raise ActiveRecord::Rollback

          end

        end

      end

    end

    puts "Updated %s records in %s" % [count, (Time.now - t1)]

  end

  desc "remove invalid images"
  task clean_images: :environment do
    # Image.find_each do |image|
    #   image.destroy if !File.exists?(image.file.path)
    # end
  end

  desc "remove duplicate releases"
  task remove_duplicates: :environment do
    sql_base = <<-SQL
      SELECT DISTINCT(t1.id)
      FROM releases t1
      WHERE (
        SELECT count(t2.id)
        FROM releases t2
        WHERE t1.name = t2.name
      ) > 1;
    SQL

    result = ActiveRecord::Base.connection.select_all sql_base

    res = []
    Release.find(result.rows).each do |release|
      release.tracks.each do |track|
        next if File.exists?(PUBLIC_PATH + track.file_url)
        res << release.id if res.exclude?(release.id)
      end
    end

    Release.find(res).each do |release|
      release.destroy
    end
  end

  desc "check releases"
  task check_releases: :environment do
    cmd = "cfv" # cfv 1.18.3
    Release.where(last_verified_at: nil).order("id desc").each do |release|
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
    Release.find_each do |release|
      path = [PUBLIC_PATH, release.path].join "/"
      allowed_formats.each do |format|
        Dir["#{path}/*.#{format}"].each do |path|
          begin
            file_name = path.split("/").last
            next if file_name =~ /.log./
            next if release.images.where(file_name: file_name).any?
            release.images.create! file: File.open(path)
          rescue
            binding.pry
            raise
          end
        end
      end
    end
  end

  desc "import NFO"
  task import_nfo: :environment do
    temp_file = "/tmp/#{Time.now.to_i}"
    font = Rails.root + "app/assets/fonts/ProFont/ProFontWindows.ttf"
    Release.includes(:images).order("id desc").each do |release|
      begin
        next if release.images.select{|item| item.file_type == "nfo" }.any?
        Dir[PUBLIC_PATH + release.path + "/*.nfo"].each do |file|
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