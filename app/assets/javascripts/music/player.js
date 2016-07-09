function init_players(tracks, browser) {
  var intervals = {}; var init;
  function reset_btn(element) {
    element.removeClass("fa-pause");
    element.addClass("fa-play");
    element.removeClass("active");
  }
  function enable_btn(element) {
    element.addClass("fa-pause");
    element.removeClass("fa-play");
    element.addClass("active");
  }
  function processing_btn(element) {
    element.hide();
    element.parent().find(".processing").removeClass("hidden");
  }
  function processing_complete_btn(element) {
    element.show();
    element.parent().find(".processing").addClass("hidden");
    element.removeClass("grey");
  }
  function enable(element, data) {
    if (element.hasClass("active")) {
        element.toggleClass("pulsate");
        window.player.paused ? window.player.play() : window.player.pause();
    } else {
        if (window.player) window.player.stop();
        if (init) return;
        init = true;
        enable_btn(element);
        new_player({
            volume: 0.5,
            url: document.location.protocol + "//" + document.location.host + data.media_url
        }, function(player) {
            window.trigger_ios_callbacks();
            window.current_file = data.id;
            window.player = player;
            window.player.play();
            init = null;
        }, function() {
            window.current_file = null;
            element.removeClass("pulsate");
            reset_btn(element);
        })
    }
  }
  function loading(element, data) {
    if (!intervals[data.id]) {
      processing_btn(element);
      intervals[data.id] = setInterval(function() {
        $.get(data.url, function(response) {
          if (response.media_url) {
            tracks[data.id].media_url = response.media_url;
            processing_complete_btn(element);
            clearInterval(intervals[data.id]);
          }
        });
      }, 2500);
    }
  }
  function observe() {
    if (!tracks) return;
    $.each($(".play-btn"), function(i, element) {
      var data = tracks[parseInt($(element).data("id"))]
      if (!data) return;
      if (!data.media_url) $(element).addClass("grey");
      if (window.current_file == data.id) enable_btn($(element));
      $(element).click(function(e) {
        data.media_url ? enable($(element), data) : loading($(element), data);
      });
    });
  }
  $(document).ready(function() {
    observe();
  });
}