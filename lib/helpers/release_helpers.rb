module ReleaseHelpers
  def year_from_name name
    name.split("-").select{|item| item.match(/(\d{4})/) }.last
  end

  def format_number name
    name.split("-").length > 2 ? name.split("-")[0] : name.split("_")[0]
  end

  def format_name name
    year = year_from_name name
    array = name.gsub("_-_", "-").gsub(".", "").split("-")
    array -= ALLOWED_SOURCES
    array -= FORMAT_NAME_STRINGS
    array[0..array.index(year)-1].join(" ").gsub("_", " ")
  end

  def format_track_format track
    case track.format_info
      when /FLAC/ then "FLAC"
      when /ALAC/ then "ALAC"
      when /WAV/ then "WAV"
      when /AIFF/ then "AIFF"
      when /MPEG ADTS, layer III|MPEG ADTS, layer II|Audio file with ID3/
        case track.release.tracks.map(&:bitrate).sum.to_f / track.release.tracks.length
          when 192.0 then "MP3-192CBR"
          when 256.0 then "MP3-256CBR"
          when 320.0 then "MP3-320CBR"
          else "MP3"
        end
      when /WAVE audio/ then "WAV"
      when /iTunes AAC/ then "iTunes AAC"
      when /MPEG v4/ then "MPEG4"
      when /clip art|BINARY|data/ then "DATA"
      else "UNKNOWN"
    end
  end
end
