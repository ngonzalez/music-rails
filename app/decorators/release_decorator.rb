class ReleaseDecorator < Draper::Decorator
  delegate_all
  def path
    [BASE_URL, self.folder, self.name].join("/")
  end
  def search_infos
    object.attributes.deep_symbolize_keys.slice(:formatted_name, :folder, :format_name, :label_name).merge(
      url: h.music_url(object, format: h.params.slice("format")), year: object.year.to_i
    )
  end
end