class ReleaseDecorator < Draper::Decorator
  delegate_all
  def path
    [self.folder, self.label_name ? self.label_name.gsub(" ","_") : nil, self.read_attribute(:source), self.name].reject(&:blank?).join("/")
  end
  def public_path
    [BASE_PATH, path].join("/")
  end
  def search_infos
    object.attributes.deep_symbolize_keys.slice(:id, :formatted_name, :folder, :format_name, :label_name).merge(year: object.year.to_i)
  end
  def scene?
    return false if !self.name
    year = self.name.split("-").select{|item| item.match(/(\d{4})/) }.last
    year && !name.ends_with?(year)
  end
end