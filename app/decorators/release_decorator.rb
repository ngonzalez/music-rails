class ReleaseDecorator < Draper::Decorator
  delegate_all
  def path
    [self.folder, self.subfolder, self.read_attribute(:source), self.name].reject(&:blank?).join("/")
  end
  def public_path
    [BASE_PATH, path].join("/")
  end
  def search_infos
    object.attributes.deep_symbolize_keys.slice(:id, :formatted_name, :folder, :format_name, :subfolder).merge(year: object.year.to_i)
  end
  def data_url
    object.formatted_name.gsub(' ', '_').downcase
  end
end