
namespace "music" do

  desc "load data"
  task load_data: :environment do

    require 'progress_bar'

    require 'taglib'

    t1 = Time.now ; count = 0

    main_folders = ["dnb","hc","other"]
    allowed_formats = ["mp3","mp4","m4a","flac","wav"]
    base_path = "/Volumes/FreeAgent\ GoFlex\ Drive/music"

    main_folders.each do |folder|

      @directories = Dir["#{base_path}/#{folder}/**"]

      puts "Update folder: #{base_path}/#{folder}/"

      bar = ProgressBar.new @directories.count

      @directories.each do |path|

        bar.increment!

        release_name = path.split("/").last

        next if Release.where(name: release_name, folder: folder).any?

        release = Release.create!(name: release_name, folder: folder)

        allowed_formats.each do |format|
          Dir["#{path}/*.#{format}"].each do |file|

            track_name = file.split("/").last
            track = release.tracks.where(name: track_name).take
            track = release.tracks.new(name: track_name) if !track

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

              track.save!

              count += 1

            end

          end
        end

      end

    end

    puts "Updated %s records in %s" % [count, (Time.now - t1)]

  end

end