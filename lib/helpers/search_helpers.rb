module SearchHelpers
  def search_db search_params
    #
    # Search by folder, subfolder
    if search_params[:folder]
      if search_params[:subfolder]
        search = Release.search {
          paginate :page => 1, :per_page => 100000
          with(:folder, search_params[:folder])
          with(:subfolder, search_params[:subfolder])
        }
      else
        search = Release.search {
          paginate :page => 1, :per_page => 100000
          with(:folder, search_params[:folder])
        }
      end
      return decorate(search).sort_by { |item| [item[:year], item[:last_verified_at]] }.reverse
    #
    # Search by year
    elsif search_params[:year]
      search = Release.search {
        paginate :page => 1, :per_page => 100000
        with(:year, search_params[:year])
      }
      return decorate(search).sort_by { |item| item[:formatted_name] }
    #
    # Fulltext search
    elsif search_params[:q]
      search = Track.search(include: [:release]) {
        fulltext search_params[:q]
        paginate :page => 1, :per_page => 100000
      }
      return decorate(search, :release).sort_by { |item| [item[:year], item[:last_verified_at]] }.reverse
    end
  end

  def get_search_params search_params
    if search_params[:q]
      q = search_params[:q].strip
      year = q.scan(/\b\d{4}\b/)[0].to_i
      year = nil if year && year.to_s.length != 4
      year = nil if year && [1,2].exclude?(year[0])
      year = nil if year && year <= 0
    end
    folder = search_params[:folder].strip if search_params[:folder]
    subfolder = search_params[:subfolder].strip if search_params[:subfolder]
    { q: q, year: year, folder: folder, subfolder: subfolder }
  end

  def decorate search, accessor=nil
    search.hits.each_with_object([]) { |hit, array|
      item = accessor ? hit.result.send(accessor) : hit.result
      next if item.nil?
      item = item.decorate.search_infos
      next if !item[:last_verified_at]
      array << item unless array.include? item
    }
  end
end
