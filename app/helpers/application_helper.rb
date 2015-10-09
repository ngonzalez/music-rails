module ApplicationHelper

  def search_terms_array
    params[:q].split(/ and | or /)
  end

  def search_rows
    100_000
  end

  def track_files release
    release.each_with_object({}) do |track, hash|
      hash[track.id] = track.file.try(:url)
    end
  end

end