module SearchHelpers
  def search_db search_params
    search_results = if search_params[:folder]
      if search_params[:subfolder]
        MusicFolder.where(folder: folder, subfolder: subfolder).take 100000
      else
        MusicFolder.where(folder: folder).take 100000
      end
    elsif search_params[:year]
      MusicFolder.where(year: year).take 100000
    elsif search_params[:q]
      AudioFile.includes(:music_folder).search(params[:q]).map(&:music_folder).take 100000
    else
      []
    end
    decorate search_results
  end

  def parse_search_params params
    q = params[:q].strip if params[:q]
    if q && year = q.scan(/\b\d{4}\b/)[0].to_i
      year = nil if year && year <= 0
      year = nil if year && year.to_s.length != 4
      year = nil if year && %w(1 2).exclude?(year.to_s[0])
    end
    folder = params[:folder].strip if params[:folder]
    subfolder = params[:subfolder].strip if params[:subfolder]
    { q: q, year: year, folder: folder, subfolder: subfolder }.compact
  end

  def decorate search_results
    item_ids = []
    search_results.each_with_object([]) { |item, array|
      next if item_ids.include?(item.id)
      array << item.decorate.attributes
      item_ids << item.id
    }.sort_by { |item| [item.year, item.folder_created_at] }.reverse
  end
end
