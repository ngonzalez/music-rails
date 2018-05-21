module SearchHelpers

  def decorate search, accessor=nil
    ids = []
    search.hits.each_with_object([]) { |hit, array|
      item = accessor ? hit.result.send(accessor) : hit.result
      item = item.decorate.search_infos
      next if ids.include? item[:id]
      ids << item[:id]
      array << item
    }
  end
  def search_db options
    q = options[:q].strip if options[:q]
    subfolder = options[:subfolder].strip if options[:subfolder]
    year = q.scan(/\b\d{4}\b/)[0].to_i if q && q.length == 4
    year = nil if year && year <= 0
    return [] if [q, subfolder, year].all? &:blank?

    if subfolder

      search = Release.search {
        paginate :page => 1, :per_page => 100000
        with(:subfolder, subfolder)
      }

      return decorate(search).sort_by { |item| item[:year] || 0 }.reverse

    elsif year

      search = Release.search {
        paginate :page => 1, :per_page => 100000
        with(:year, year)
      }

      return decorate(search).sort_by { |item| item[:formatted_name] || 0 }

    elsif q

      search = Track.search(include: [:release]) {
        fulltext q
        paginate :page => 1, :per_page => 100000
      }

      return decorate(search, :release).sort_by { |item| item[:year] || 0 }.reverse
    end
  end
end