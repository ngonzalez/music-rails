
function observe_btn() {
  function init_player(file_uri) {
    if (typeof AV != "undefined") {
      return $.extend(AV.Player.fromURL(file_uri), {
        is_paused: function() {
          return !window.player.playing;
        }
      });
    } else {
      if (window.player && window.player.attributes) {
        $(window.player).attr("src", file_uri);
        return window.player;
      } else {
        $("body").append(
          $(document.createElement("audio"))
                    .attr("src", file_uri)
                    .addClass("hidden")
        );
        return $.extend($("audio").get(0), {
          stop: function() {
            $(window.player).attr("src", "");
          },
          is_paused: function() {
            return window.player.paused;
          }
        });
      }
    }
  }
  function clear_active() {
    $.each($(".play-btn.active"), function(i, element) {
      $(element).removeClass("pulsate");
      reset_btn($(element));
    });
  }
  function reset_btn(element) {
    element.removeClass("fa-pause");
    element.addClass("fa-play-circle");
    element.removeClass("active");
  }
  function enable_btn(element) {
    element.addClass("fa-pause");
    element.removeClass("fa-play-circle");
    element.addClass("active");
  }
  $.each($('.play-btn'), function(i, element) {
    if ($(element).data("uri") == window.current_file) enable_btn($(element));
    $(element).click(function(e) {
      if ($(element).hasClass("active")) {
        $(e.target).toggleClass("pulsate");
        window.player.is_paused() ? window.player.play() : window.player.pause();
      } else {
        if (window.player) {
          window.player.stop();
          clear_active();
        }
        enable_btn($(e.target));
        window.player = init_player($(e.target).data("uri"));
        window.current_file = $(e.target).data("uri");
        window.player.play();
        setTimeout(function() {
          reset_btn($(e.target));
        }, Number($(e.target).data("length")) * 1000);
      }
    });
  });
  $(window).bind('beforeunload', function() {
    if (window.player) {
      window.player.stop();
      window.player = "undefined";
    }
  }); 
}
