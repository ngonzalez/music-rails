module TracksHelper
  def default_transition
    { "data-transition" => "none" }
  end
  def authorized_search_params
    search_params.slice :q, :folder, :subfolder
  end
end
