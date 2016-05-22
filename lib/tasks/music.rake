
namespace "music" do

  desc "update data"
  task update: :environment do
    ["load_data", "set_details"].each do |name|
      Rake::Task["music:#{name}"].execute
    end
  end

  desc "set details"
  task set_details: :environment do
    def format_number name
      name.split("-").length > 2 ? name.split("-")[0] : name.split("_")[0]
    end
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
    # Set Release Audio Format Name
    Release.joins(:tracks).includes(:tracks).each do |release|
      format_name = get_format_from_release_name release
      format_name = format_track_format(release.tracks[0]) if !format_name
      release.update! format_name: format_name, year: release.tracks[0].year.to_i
      release.tracks.where(format_name: nil).each do |track|
        track.update! format_name: format_track_format(track)
      end
    end
  end

  desc "load data"
  task load_data: :environment do
    require 'taglib'

    def import_release folder, path, source, label_name
      release_name = path.split("/").last
      release = Release.find_by name: release_name
      return if release

      formatted_label_name = label_name.gsub("_"," ")

      ActiveRecord::Base.transaction do

        begin

          release = Release.create!(name: path.split("/").last, folder: folder, source: source, label_name: label_name)

          ALLOWED_AUDIO_FORMATS.each do |format|
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
    def import_images path
      release_name = path.split("/").last
      release = Release.find_by name: release_name
      ALLOWED_IMAGE_FORMATS.each do |format|
        Dir["#{path}/*.#{format}"].each do |image_path|
          file_name = image_path.split("/").last
          next if file_name =~ /.log./
          next if release.images.where(file_name: file_name).any?
          release.images.create! file: File.open(image_path)
        end
      end
    end
    def import_nfo path
      release_name = path.split("/").last
      release = Release.find_by name: release_name
      return if release.images.select{|item| item.file_type == NFO_TYPE }.any?
      temp_file = "/tmp/#{Time.now.to_i}"
      font = Rails.root + "app/assets/fonts/ProFont/ProFontWindows.ttf"
      [NFO_TYPE].each do |format|
        Dir["#{path}/*.#{format}"].each do |nfo_path|
          file_name = nfo_path.split("/").last
          begin
            File.open(temp_file, 'w:UTF-8') do |f|
              File.open(nfo_path).each_line do |line|
                # Remove ^M when copy files from Windows
                # https://en.wikipedia.org/wiki/Code_page_437
                f.write line.gsub("\C-M", "").force_encoding("CP437")
              end
            end
            content = Dragonfly.app.generate(:text, "@#{temp_file}", { 'font': font.to_s, 'format': 'svg' })
            release.images.create! file: content, file_type: NFO_TYPE
          rescue
            next
          end
        end
      end
      FileUtils.rm(temp_file) if File.exists?(temp_file)
    end
    def check_sfv path
      release_name = path.split("/").last
      release = Release.find_by name: release_name
      return if release.last_verified_at
      return if !release.details.empty? && release.details.has_key?("sfv")
      cmd = "cfv" # cfv 1.18.3
      if Dir["#{path}/*.sfv"].empty? # No SFV
        release.update! details: { "sfv" => "not found" }
        return
      end
      details = case Dir.chdir(path) { %x[#{cmd}] }
        when /badcrc/ then "badcrc"
        when /chksum file errors/ then "chksum file errors"
        when /not found/ then "missing files"
      end
      release.update! details: { "sfv" => details } if details && release.details['sfv'] != details
      release.update! last_verified_at: Time.now
    end

    ["dnb","hc","other"].each do |folder|
      ALLOWED_SOURCES.each do |source|
        Dir["#{BASE_PATH}/#{folder}/#{source}/**"].each do |path|
          import_release folder, path, source, "--"
          import_images path
          import_nfo path
          check_sfv path
        end
      end
    end

    Dir["#{BASE_PATH}/backup/**"].each do |label_path|
      label_name = label_path.split("/").last
      ALLOWED_SOURCES.each do |source|
        Dir["#{BASE_PATH}/backup/#{label_name}/#{source}/**"].each do |path|
          import_release "backup", path, source, label_name
          import_images path
          import_nfo path
          check_sfv path
        end
      end
    end
  end

end