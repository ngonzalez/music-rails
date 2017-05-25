module ApplicationHelper

  def default_transition
    { "data-transition" => "none" }
  end

  def permitted_params
    params.permit(:format, :q, :subfolder, :label)
  end

  def default_params
    permitted_params.slice "format", "q", "subfolder"
  end

  def search_terms_array
    return if !permitted_params[:q]
    permitted_params[:label] || permitted_params[:q].split(/ and | or /)
  end

  def asset_url asset
    return asset_path(asset)
  end

  def track_files
    @tracks.each_with_object({}) do |track, hash|
      hash[track.id] = {
        id: track.id,
        media_url: track.media_url,
        url: track_path(track, format: :json)
      }
    end
  end

end