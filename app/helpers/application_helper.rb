module ApplicationHelper

  def search_terms_array
    params[:q].split(/ and | or /)
  end

  def search_rows
    100_000
  end

end