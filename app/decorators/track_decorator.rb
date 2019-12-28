class TrackDecorator < Draper::Decorator
  delegate_all
  def public_path
    [BASE_PATH, release.decorate.path, name].join("/")
  end
  def link_to_search name
    h.link_to h.search_music_index_path(q: object.send(name)), h.default_transition do
      h.highlight object.send(name), h.search_terms_array
    end
  end
  def duration
    Time.at(object.length).strftime(object.length.to_i > 3600 ? "%H:%M:%S" : "%M:%S")
  end
  [:title, :album, :genre].each do |name|
    define_method name do
      h.highlight object.send(name), h.search_terms_array
    end
  end
  def format_name
    case object.format_info
      when /FLAC/ then "FLAC"
      when /ALAC/ then "ALAC"
      when /WAV/ then "WAV"
      when /AIFF/ then "AIFF"
      when /MPEG ADTS, layer III|MPEG ADTS, layer II|Audio file with ID3/ then "MP3"
      when /WAVE audio/ then "WAV"
      when /iTunes AAC/ then "iTunes AAC"
      when /MPEG v4/ then "MPEG4"
      when /clip art|BINARY|data/ then "DATA"
      else "UNKNOWN"
    end
  end
  def m3u8_exists?
    File.exists? m3u8_path rescue false
  end
  def m3u8_path
     "#{HLS_FOLDER}/#{object.id}.m3u8"
  end
  def url_infos
    hash = {}
    hash.merge! stream_url: "http://#{HOST_NAME}/hls/#{object.id}.m3u8" if m3u8_exists?
    return hash
  end
  def details
    OpenStruct.new(
          object.attributes.deep_symbolize_keys
          .slice(:id)
          .merge(url_infos)
    )
  end
end
