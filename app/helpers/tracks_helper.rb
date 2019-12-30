module TracksHelper
  def default_transition
    { "data-transition" => "none" }
  end
  def search_terms_array
    search_params[:q].split(/ and | or /) if search_params[:q]
  end
  def tracks_css
    {
      :hidden     => 'hidden',
      :play_btn   => 'fa-google-play',
      :processing => 'fa-cog',
    }
  end
  def play_btn track
    content_tag :i, nil, class: "fab fa-3 %s" % tracks_css[:play_btn], data: { id: track.id }
  end
  def processing_btn
    content_tag :i, nil, class: "fas fa-3 fa-spin %s %s" % [tracks_css[:processing], tracks_css[:hidden]]
  end
end