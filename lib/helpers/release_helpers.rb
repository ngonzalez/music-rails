module ReleaseHelpers
  def year_from_name name
    name.split("-").select{|item| item.match(/(\d{4})/) }.last
  end

  def format_number name
    name.split("-").length > 2 ? name.split("-")[0] : name.split("_")[0]
  end

  def format_name name
    year = year_from_name name
    array = name.gsub("_-_", "-").gsub(".", "").split("-")
    array -= ALLOWED_SOURCES
    array -= FORMAT_NAME_STRINGS
    array[0..array.index(year)-1].join(" ").gsub("_", " ")
  end
end
