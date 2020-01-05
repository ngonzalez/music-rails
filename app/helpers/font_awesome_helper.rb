module FontAwesomeHelper
  def fa_css
    {
      :disabled   => 'disabled',
      :hidden     => 'hidden',
      :play       => 'fa-google-play',
      :processing => 'fa-cog',
    }
  end
  def fa_play options={}
    content_tag :i, nil, options.merge(class: "fab fa-3 %s" % fa_css[:play])
  end
  def fa_processing options={}
    content_tag :i, nil, options.merge(class: "fas fa-3 fa-spin %s hidden" % fa_css[:processing])
  end
end
