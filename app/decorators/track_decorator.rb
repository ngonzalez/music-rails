class TrackDecorator < Draper::Decorator
  delegate_all
  def link_to_search name
    h.link_to h.search_music_index_path(rows: h.search_rows, q: object.send(name)), { "data-transition" => "none" } do
      h.highlight object.send(name), h.search_terms_array
    end
  end
  def duration
    Time.at(object.length).utc.strftime(object.length.to_i > 3600 ? "%H:%M:%S" : "%M:%S")
  end
  [:title, :album, :genre].each do |name|
    define_method name do
      h.highlight(object.send(name), h.search_terms_array)
    end
  end
  def number
    object.name.split("-").length > 2 ? object.name.split("-")[0] : object.name.split("_")[0]
  end
  def file_url
    [ object.release.decorate.path, object.name ].join("/")
  end
  def file_extension
    name.split(".").last
  end
end