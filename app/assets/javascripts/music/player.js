function init_players(tracks) {
  var intervals = {};
  function reset_btn(element) {
    element.removeClass(is_safari_osx() ? "fa-stop" : "fa-pause");
    element.addClass("fa-play");
    element.removeClass("active");
  }
  function enable_btn(element) {
    element.addClass(is_safari_osx() ? "fa-stop" : "fa-pause");
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
  function is_safari_osx() {
      return !window.navigator.userAgent.match(/iPad|iPhone/i) && /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
  }
  function enable(element, data) {
    if (element.hasClass("active")) {
        if (is_safari_osx()) {
            window.player.playing ? window.player.stop() : window.player.play();
        } else {
            element.toggleClass("pulsate");
            window.player.paused ? window.player.play() : window.player.pause();
        }
    } else {
      if (window.player) window.player.stop();
      enable_btn(element);
      window.current_file = data.id;
      var url = document.location.protocol + "//" + document.location.host + data.media_url;
      if (is_safari_osx()) {
          new_player({ volume: 0.5, url: url }, function(player) {
              window.player = player
              window.player.play()
          }, function() {
              window.current_file = null;
              $(element).removeClass("pulsate");
              reset_btn($(element));
          })
      } else {
          window.player = $.extend(new Audio(url), {
            stop: function() {
              window.player.src = "";
              window.player = null;
              window.current_file = null;
              $(element).removeClass("pulsate");
              reset_btn($(element));
            },
          });
          window.player.play()
      }
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