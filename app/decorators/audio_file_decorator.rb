class AudioFileDecorator < Draper::Decorator
  delegate_all
  attr_accessor :m3u8_exists
  def path
    [music_folder.decorate.path, name].join "/"
  end
  def public_path
    [BASE_PATH, path].join "/"
  end
  def year
    object.year.to_i
  end
  def url
    h.audio_file_path object, format: :json
  end
  def artist_url
    h.music_folders_path q: object.artist
  end
  def year_url
    h.music_folders_path q: object.year
  end
  def duration
    Time.at(object.length_in_seconds).strftime object.length_in_seconds.to_i > 3600 ? "%H:%M:%S" : "%M:%S"
  end
  def format_name
    ALLOWED_AUDIO_FORMATS.detect { |_, format| format[:tags].any? { |tag| object.format_info =~ /#{tag}/ } }[0]
  end
  def number
    object.name.split("-").length > 2 ? object.name.split("-")[0] : object.name.split("_")[0]
  end
  def url_infos
    hash = { url: url, artist_url: artist_url, year_url: year_url }
    hash.merge! stream_url: "http://#{HOST_NAME}/hls/#{object.id}.m3u8"
    hash
  end
  def m3u8_exists?
    File.exists? "#{HLS_FOLDER}/#{object.id}.m3u8" rescue false
  end
  def attr_infos
    hash = {}
    hash.merge! m3u8_exists: m3u8_exists?
    hash
  end
  def attributes
    OpenStruct.new(
      object.attributes.deep_symbolize_keys
      .slice(:id, :album, :artist, :title, :year, :genre)
      .merge(duration: duration, year: year)
      .merge(url_infos)
      .merge(attr_infos)
      .compact
    )
  end
  def to_json
    attributes.marshal_dump.to_json
  end
end
