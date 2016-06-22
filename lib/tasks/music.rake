
namespace "music" do

  desc "update data"
  task update: :environment do
    ["clear_data", "load_data", "set_details"].each do |name|
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
      year = release.name.scan(/\b\d{4}\b/)[0].to_i
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
          ImportWorker.perform_async folder: folder, path: path, source: source
          bar.increment!
        end
      end
    end

    Dir["#{BASE_PATH}/backup/**"].each do |label_path|
      label_name = label_path.split("/").last
      ALLOWED_SOURCES.each do |source|
        Dir["#{BASE_PATH}/backup/#{label_name}/#{source}/**"].each do |path|
          ImportWorker.perform_async folder: "backup", path: path, source: source, label_name: label_name
          bar.increment!
        end
      end
    end

  end

end
