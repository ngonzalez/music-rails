module TaskHelpers

  class SrrdbLimitReachedError < StandardError ; end

  def import_srrdb_sfv release
    url = ["http://www.srrdb.com/download/file"]
    url << release.name
    url << release.sfv_name
    return if release.details[:srrdb_sfv_error]
    response = Typhoeus.get url.join("/")
    if response.code != 200 || response.body.blank?
      release.details[:srrdb_sfv_error] = true
      release.save!
      return
    end
    content = response.body.force_encoding('Windows-1252').encode('UTF-8')
    raise SrrdbLimitReachedError.new content if content == "You've reached the daily limit."
    f = Tempfile.new ; f.write(content) ; f.rewind
    release.update! srrdb_sfv: f
    f.unlink
  end

  def check_sfv release, field_name, key
    return if release.send(field_name) || release.details[key] || !release.send(key)
    Rails.logger.info "\scheck_sfv -> #{release.id}"
    details = case Dir.chdir(release.decorate.public_path) { %x[#{SFV_CHECK_APP} -f #{release.send(key).path}] }
      when /badcrc/ then :bad_crc
      when /chksum file errors/ then :chksum_file_errors
      when /not found|No such file/ then :missing_files
    end
    if details
      release.details[key] = details
      release.save!
    else
      release.update! field_name => Time.now
    end
  end

  def format_number name
    name.split("-").length > 2 ? name.split("-")[0] : name.split("_")[0]
  end

  def format_name name
    year = name.split("-").select{|item| item.match(/(\d{4})/) }.last
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

end