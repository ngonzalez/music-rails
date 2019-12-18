module SearchHelpers
  def search_db options
    q, subfolder, year = get_search_params options
    return [] if [q, subfolder, year].all? &:blank?

    if subfolder
      search = Release.search {
        paginate :page => 1, :per_page => 100000
        with(:subfolder, subfolder)
      }
      return decorate(search).sort_by { |item| [-item[:year], item[:formatted_name].downcase] || 0 }

    elsif year
      search = Release.search {
        paginate :page => 1, :per_page => 100000
        with(:year, year)
      }
      return decorate(search).sort_by { |item| item[:formatted_name].downcase || 0 }

    elsif q
      search = Track.search(include: [:release]) {
        fulltext q
        paginate :page => 1, :per_page => 100000
      }
      return decorate(search, :release).sort_by { |item| [-item[:year], item[:formatted_name].downcase] || 0 }

    end
  end

  def get_search_params options
    q = nil ; subfolder = nil ; year = nil
    if options[:q]
      q = options[:q].strip
      year = q.scan(/\b\d{4}\b/)[0].to_i if q && q.length == 4
      year = nil if year && year <= 0
    elsif options[:subfolder]
      subfolder = options[:subfolder].strip
    end
    [q, subfolder, year]
  end

  def decorate search, accessor=nil
    search.hits.each_with_object([]) { |hit, array|
      item = accessor ? hit.result.send(accessor) : hit.result
      next if item.nil?
      item = item.decorate.search_infos
      array << item unless array.include? item
    }
  end
end
