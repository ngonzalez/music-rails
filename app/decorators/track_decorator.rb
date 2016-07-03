class TrackDecorator < Draper::Decorator
  delegate_all
  def public_path
    [BASE_PATH, release.decorate.path, name].join("/")
  end
  def link_to_search name
    h.link_to h.search_music_index_path(rows: h.search_rows, q: object.send(name)), h.default_transition do
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
  def media_url
    return if !track.file_uid
    return h.asset_url track.file.url
  end
end