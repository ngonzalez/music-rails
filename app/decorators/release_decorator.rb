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
    h.search_music_index_path h.default_params.merge(folder: nil, subfolder: nil, q: object.year)
  end
  def folder_url
    h.search_music_index_path h.default_params.merge(folder: object.folder, subfolder: nil, q: nil)
  end
  def subfolder_url
    h.search_music_index_path h.default_params.merge(folder: object.folder, subfolder: object.subfolder, q: nil)
  end
  def folder_name
    object.folder.titleize.truncate 20, omission: "…#{object.folder.titleize.last(10)}"
  end
  def subfolder_name
    object.subfolder.titleize.truncate 20, omission: "…#{object.subfolder.titleize.last(10)}"
  end
  def url_infos
    hash = { url: url, year_url: year_url }
    hash.merge! folder_name: folder_name, folder_url: folder_url
    hash.merge! subfolder_name: subfolder_name, subfolder_url: subfolder_url if object.subfolder
    return hash
  end
  def search_infos
    OpenStruct.new(
          object.attributes.deep_symbolize_keys
          .slice(:id, :formatted_name, :folder, :format_name, :subfolder)
          .merge(folder_created_at: object.folder_created_at.try(:strftime, "%Y-%m-%d"))
          .merge(year: object.year.to_i)
          .merge(url_infos)
    )
  end
end
