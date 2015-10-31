function init_players(tracks) {
  var intervals = {};
  function clear_active() {
    $.each($(".play-btn.active"), function(i, element) {
      $(element).removeClass("pulsate");
      reset_btn($(element));
    });
  }
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
    function init_player(url, callback) {
      window.player = $.extend(new Audio(url), {
        stop: function() {
          window.player.src = "";
          window.player = null;
        },
        toggle: function() {
          if (window.player.paused) {
            window.player.play();
          } else {
            window.player.pause();
          }
        }
      });
      // window.player.addEventListener("canplay", window.player.play);
      window.player.addEventListener("ended", callback);
      window.player.load();
      window.player.play();
    }
    function complete() {
      if (window.player) window.player.stop();
      window.current_file = null;
      clear_active();
    }
    if (element.hasClass("active")) {
      element.toggleClass("pulsate");
      window.player.toggle();
    } else {
      if (window.player) complete();
      enable_btn(element);
      window.current_file = data.id;
      init_player(data.media_url, complete);
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