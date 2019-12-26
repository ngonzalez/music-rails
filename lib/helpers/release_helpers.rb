module ReleaseHelpers
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
    array = name.gsub("_-_", "-").gsub("(", "").gsub(")", "").gsub(".", "").split("-")
    array -= ALLOWED_SOURCES
    array -= ["Promo_CD", "Promo_CDS", "Promo_WEB"]
    array -= ["VA", "CDS", "REPACK", "7INCH", "VINYL", "VLS"]
    array -= ["WAV", "FLAC", "AIFF", "ALAC"]
    array.reject! &:blank?
    array.each_with_object([]){|string, array|
      next if array.include? year
      array << string.gsub("_", " ")
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

  def run_check_sfv release, sfv_file
    m3u_file = find_m3u release, sfv_file
    return :failed if !m3u_file
    files_count = m3u_file.decorate.file_names.length
    case Dir.chdir([release.decorate.public_path, sfv_file.base_path].join('/')) { %x[cfv -f #{sfv_file.file.path}] }
      when /#{files_count} files, #{files_count} OK/ then :ok
      when /badcrc/ then :bad_crc
      when /chksum file errors/ then :chksum_file_errors
      when /not found|No such file/ then :missing_files
    end
  end

  def find_m3u release, sfv_file
    m3u_file = release.m3u_files.local.select { |item| item.file_name =~ /^0{2,3}/ }.detect { |item| item.base_path.try(:downcase) == sfv_file.base_path.try(:downcase) }
    m3u_file = release.m3u_files.local.select { |item| item.file_name =~ /0{2,3}/  }.detect { |item| item.base_path.try(:downcase) == sfv_file.base_path.try(:downcase) } if !m3u_file
    m3u_file = release.m3u_files.local.detect { |item| item.base_path.try(:downcase) == sfv_file.base_path.try(:downcase) } if !m3u_file
    return m3u_file
  end
end
