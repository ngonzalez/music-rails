class TrackDecorator < Draper::Decorator
  delegate_all
  def public_path
    [BASE_PATH, release.decorate.path, name].join("/")
  end
  def duration
    Time.at(object.length).strftime(object.length.to_i > 3600 ? "%H:%M:%S" : "%M:%S")
  end
  def format_name
    ALLOWED_AUDIO_FORMATS.detect { |_, format| format[:tags].any? { |tag| object.format_info =~ /#{tag}/ } }[0]
  end
  def number
    object.name.split("-").length > 2 ? object.name.split("-")[0] : object.name.split("_")[0]
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
