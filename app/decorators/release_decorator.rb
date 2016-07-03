class ReleaseDecorator < Draper::Decorator
  delegate_all
  def path
    [self.folder, self.label_name ? self.label_name.gsub(" ","_") : nil, self.read_attribute(:source), self.name].reject(&:blank?).join("/")
  end
  def public_path
    [BASE_PATH, path].join("/")
  end
  def search_infos
    object.attributes.deep_symbolize_keys.slice(:id, :formatted_name, :folder, :format_name, :label_name).merge(
      url: h.music_url(object, format: h.params.slice("format")), year: object.year.to_i
    )
  end
  def year_from_name
    name.split("-").select{|item| item.match(/(\d{4})/) }.last
  end
end