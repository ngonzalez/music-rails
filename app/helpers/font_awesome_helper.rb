module FontAwesomeHelper
  def fa_css
    {
      :hidden     => 'hidden',
      :play       => 'fa-google-play',
      :processing => 'fa-cog',
    }
  end
  def fa_play_btn data
    content_tag :i, nil, class: "fab fa-3 %s" % fa_css[:play], data: data
  end
  def fa_processing_btn
    content_tag :i, nil, class: "fas fa-3 fa-spin %s %s" % [fa_css[:processing], fa_css[:hidden]]
  end
end
