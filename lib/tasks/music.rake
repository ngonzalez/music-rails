
namespace "music" do

  desc "set format names"
  task set_format_names: :environment do

    def format_track_format track
      case track.format
        when /FLAC/ then "FLAC"
        when /MPEG ADTS, layer III, v1, 320 kbps/ then "MP3-320CBR"
        when /MPEG ADTS, layer III, v1, 192 kbps/ then "MP3-192CBR"
        when /MPEG ADTS, layer III|MPEG ADTS, layer II|Audio file with ID3/
          case track.release.tracks.map(&:bitrate).sum / track.release.tracks.length
            when 192 then "MP3-192CBR"
            when 320 then "MP3-320CBR"
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
        # when /\-WEB\-/ then "MP3-320CBR"
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
    allowed_formats = ["mp3","mp4","m4a","flac","wav"]

    main_folders.each do |folder|

      @directories = Dir["#{BASE_PATH}/#{folder}/**"]

      puts "Update folder: #{BASE_PATH}/#{folder}/"

      bar = ProgressBar.new @directories.count

      @directories.each do |path|

        bar.increment!

        release_name = path.split("/").last

        # next if Release.where(name: release_name, folder: folder).any?

        release = Release.find_by(name: release_name, folder: folder)

        release = Release.create!(name: release_name, folder: folder) if !release

        allowed_formats.each do |format|
          Dir["#{path}/*.#{format}"].each do |file|

            track_name = file.split("/").last
            track = release.tracks.where(name: track_name).take
            if !track

              track = release.tracks.new(name: track_name)

              track.format = `file -b #{Shellwords.escape(file)}`.force_encoding('Windows-1252').encode('UTF-8').gsub("\n", "")

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

            end

            track.save!

            count += 1

          end
        end

      end

    end

    puts "Updated %s records in %s" % [count, (Time.now - t1)]

  end

  desc "remove duplicates"
  task remove_duplicates: :environment do

    res = []

    [
      "Lenzman-Looking_At_The_Stars_Remix_EP-META030D-WEB-2015",
      "Optiv__Btk-Dive_Bomb-VRS033-WEB-2015-PITY",
      "DRS-Mid_Mic_Crisis-2015-uC",
      "Kimyan_Law-Coeur_Calme-2014-uC",
      "Future_Brown-Future_Brown-WEB-2015-ANGER",
      "Alix_Perez_&_EPROM-Shades_EP-APR076-WEB-2105"
    ].each do |name|

      releases = Release.where(name: name)

      releases.each do |release|
        release.tracks.each do |track|
          next if File.exists?("/usr/local/var/www/" + track.file_url)
          res << release.id if res.exclude?(release.id)
        end
      end
      
    end

    Release.find(res).each do |release|
      release.destroy
    end

  end

end