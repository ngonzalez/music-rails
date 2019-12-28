module ApplicationHelper
  def default_transition
    { "data-transition" => "none" }
  end

  def permitted_params
    params.permit(:format, :q, :folder, :subfolder)
  end

  def default_params
    permitted_params.slice "format", "q", "folder", "subfolder"
  end

  def search_terms_array
     permitted_params[:q].split(/ and | or /) if permitted_params[:q]
  end

  def track_files tracks
    tracks.each_with_object({}) do |track, hash|
      hash[track.id] = {
        id: track.id,
        url: track_path(track, format: :json),
      }
    end
  end
end
