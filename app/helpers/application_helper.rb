module ApplicationHelper

  def default_transition
    { "data-transition" => "none" }
  end

  def default_params
    params.slice("format", "q", "rows")
  end

  def search_terms_array
    params[:q].split(/ and | or /)
  end

  def search_rows
    100_000
  end

  def track_files
    @tracks.each_with_object({}) do |track, hash|
      hash[track.id] = {
        id: track.id,
        media_url: track.file.try(:url),
        url: track_path(track, format: :json)
      }
    end
  end

end