class ReleaseDecorator < Draper::Decorator
  delegate_all
  def path
    [folder, subfolder, read_attribute(:source), name].reject(&:blank?).join("/")
  end
  def public_path
    [BASE_PATH, path].join("/")
  end
  def year
    object.year.to_i
  end
  def url
    h.music_path object
  end
  def year_url
    h.music_index_path q: object.year
  end
  def folder_url
    h.music_index_path folder: object.folder
  end
  def subfolder_url
    h.music_index_path folder: object.folder, subfolder: object.subfolder
  end
  def track_urls
    object.tracks.each_with_object({}) { |track, hash| hash[track.id] = { id: track.id, url: h.track_path(track, format: :json) } }
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
  def details
    OpenStruct.new(
      object.attributes.deep_symbolize_keys
      .slice(:id, :formatted_name, :folder, :subfolder, :folder_created_at)
      .merge(year: year)
      .merge(url_infos)
    )
  end
end
