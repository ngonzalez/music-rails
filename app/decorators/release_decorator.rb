class ReleaseDecorator < Draper::Decorator
  delegate_all
  def path
    [self.folder, self.subfolder, self.read_attribute(:source), self.name].reject(&:blank?).join("/")
  end
  def public_path
    [BASE_PATH, path].join("/")
  end
  def search_infos
    url_infos = {
      url: h.music_path(object, h.default_params),
      year_url: h.search_music_index_path(h.default_params.merge(q: object.year, subfolder: nil))
    }
    if object.subfolder
      url_infos.merge! subfolder_url: h.search_music_index_path(h.default_params.merge(subfolder: object.subfolder, q: nil))
    end
    object.attributes
          .deep_symbolize_keys
          .slice(:id, :formatted_name, :folder, :format_name, :subfolder)
          .merge(year: object.year.to_i)
          .merge(url_infos)
  end
end