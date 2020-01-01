module TracksHelper
  def default_transition
    { "data-transition" => "none" }
  end
  def search_terms_array
    search_params[:q].split(/ and | or /) if search_params[:q]
  end
  def authorized_search_params
    search_params.slice :q, :folder, :subfolder
  end
end
