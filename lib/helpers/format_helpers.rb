module FormatHelpers
  def release_set_details
    Track.where(number: nil).each do |track|
      track.update! number: format_number(track.name)
    end
    Release.where(formatted_name: nil).each do |release|
      release.update! formatted_name: format_name(release.name)
    end
    Release.where(data_url: nil).each do |release|
      data_url = release.formatted_name.downcase.gsub(' ', '-').gsub('_', '-').gsub('__', '-').gsub('--', '-')
      begin
        release.update! data_url: data_url
      rescue ActiveRecord::RecordNotUnique
        release.update! data_url: [data_url, rand(1000) * rand(1000)].join('-')
      end
    end
    Release.where(year: nil).each do |release|
      next if release.tracks.empty?
      release.update! year: release.tracks[0].year.to_i
    end
    Release.where("year::numeric = 0 OR year IS NULL").find_each do |release|
      year = year_from_name release.name
      next if !year
      release.tracks.each{|track| track.update! year: year }
      release.update! year: year
    end
    Release.where(format_name: nil).each do |release|
      release.update! format_name: get_format_from_release_name(release) || format_track_format(release)
    end
    Release.includes(:tracks).where(tracks: { format_name: nil }).each do |release|
      release.tracks.each{|track| track.update! format_name: format_track_format(release) }
    end
    Release.where(folder_created_at: nil, folder_updated_at: nil).each do |release|
      f = File::Stat.new release.decorate.public_path
      release.update! folder_created_at: f.birthtime, folder_updated_at: f.mtime
    end
  end
  def year_from_name name
    res = name.split("-").select{|item| item.match(/(\d{4})/) }.last
    res = '1999' if ['199','99','19'].include?(res)
    res = '2000' if res == '200'
    return res
  end
  def format_number name
    name.split("-").length > 2 ? name.split("-")[0] : name.split("_")[0]
  end
  def format_name name
    year = year_from_name name
    name.gsub("_-_", "-").gsub("(", "").gsub(")", "").gsub(".", "").split("-").each_with_object([]){|string, array|
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
    case release.tracks[0].format_info
      when /FLAC/ then "FLAC"
      when /MPEG ADTS, layer III, v1, 192 kbps/ then "MP3-192CBR"
      when /MPEG ADTS, layer III, v1, 256 kbps/ then "MP3-256CBR"
      when /MPEG ADTS, layer III, v1, 320 kbps/ then "MP3-320CBR"
      when /MPEG ADTS, layer III|MPEG ADTS, layer II|Audio file with ID3/
        case release.tracks.map(&:bitrate).sum.to_f / release.tracks.length
          when 192.0 then "MP3-192CBR"
          when 256.0 then "MP3-256CBR"
          when 320.0 then "MP3-320CBR"
          else "MP3"
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
end