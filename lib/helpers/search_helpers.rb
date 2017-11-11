module SearchHelpers
  def search_db options
    q = options[:q].strip if options[:q]
    subfolder = options[:subfolder].strip if options[:subfolder]
    year = q.scan(/\b\d{4}\b/)[0].to_i if q && q.length == 4
    return [] if [q, subfolder, year].all? &:blank?
    hash = {}
    if subfolder
      # Search by subfolder
      search = Release.search {
        paginate :page => 1, :per_page => 100000
        with(:subfolder, subfolder)
      }
      search.hits.each { |hit| hash[hit.result.id] = hit.result.decorate.search_infos }
      return hash.sort_by { |k, v| v[:year] || 0 }.reverse

    elsif year && year > 0
      # Search by year
      search = Release.search {
        paginate :page => 1, :per_page => 100000
        with(:year, year)
      }
      search.hits.each { |hit| hash[hit.result.id] = hit.result.decorate.search_infos }
      return hash.sort_by { |k, v| v[:formatted_name] || 0 }

    elsif q
      # Search by name
      search = Track.search(include: [:release]) {
        fulltext q
        paginate :page => 1, :per_page => 100000
      }
      search.hits.each { |hit| hash[hit.result.release_id] = hit.result.release.decorate.search_infos }
      return hash.sort_by { |k, v| v[:year] || 0 }.reverse
    end
  end
end