module SearchHelpers
  def search_db search_params
    #
    # Search by folder, subfolder
    if search_params[:folder]
      if search_params[:subfolder]
        search = Folder.search {
          paginate :page => 1, :per_page => 100000
          with(:folder, search_params[:folder])
          with(:subfolder, search_params[:subfolder])
        }
      else
        search = Folder.search {
          paginate :page => 1, :per_page => 100000
          with(:folder, search_params[:folder])
        }
      end
      return decorate(search)
    #
    # Search by year
    elsif search_params[:year]
      search = Folder.search {
        paginate :page => 1, :per_page => 100000
        with(:year, search_params[:year])
      }
      return decorate(search)
    #
    # Fulltext search
    elsif search_params[:q]
      search = AudioFile.search(include: [:release]) {
        fulltext search_params[:q]
        paginate :page => 1, :per_page => 100000
      }
      return decorate(search, :release)
    end
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

  def decorate search, accessor=nil
    item_ids = []
    search.hits.each_with_object([]) { |hit, array|
      next if hit.result.nil?
      item = accessor ? hit.result.send(accessor) : hit.result
      next if item_ids.include?(item.id)
      array << item.decorate.attributes
      item_ids << item.id
    }.sort_by { |item| [item.year, item.folder_created_at] }.reverse
  end
end
