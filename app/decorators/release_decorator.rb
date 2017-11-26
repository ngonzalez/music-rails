class ReleaseDecorator < Draper::Decorator
  delegate_all
  def path
    [folder, subfolder, read_attribute(:source), name].reject(&:blank?).join("/")
  end
  def public_path
    [BASE_PATH, path].join("/")
  end
  def url
    h.music_path object, h.default_params
  end
  def year_url
    h.search_music_index_path h.default_params.merge(q: object.year, subfolder: nil)
  end
  def subfolder_url
    h.search_music_index_path h.default_params.merge(subfolder: object.subfolder, q: nil)
  end
  def url_infos
    hash = { url: url, year_url: year_url }
    hash.merge!(subfolder_url: subfolder_url) if object.subfolder
    return hash
  end
  def search_infos
    OpenStruct.new(
          object.attributes.deep_symbolize_keys
          .slice(:id, :formatted_name, :folder, :format_name, :subfolder)
          .merge(year: object.year.to_i)
          .merge(url_infos)
    )
  end
end