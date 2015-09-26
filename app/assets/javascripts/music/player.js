
function observe_btn(options) {
  function load_file(file_uri) {
    window["current_file"] = file_uri;
    if (typeof AV != "undefined") {
      window["player"] = AV.Player.fromURL(file_uri);
    } else {
      if ($("audio").length > 0) {
        if ($("audio").attr("src") != file_uri) {
          $("audio").attr("src", file_uri);
        }
      } else {
        $("body").append(
          $(document.createElement("audio"))
                    .attr("src", file_uri)
                    .addClass("hidden")
        );
        window["player"] = $.extend($("audio").get(0), {
          stop: function() {
            $("audio").attr("src", "");
          }
        })
      }
    }
  }
  function clear_active() {
    $.each($(".play-btn.pulsate"), function(i, element) {
      $(element).removeClass("pulsate");
    });
    $.each($(".play-btn.active"), function(i, element) {
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
    if (typeof(window.current_file) != "undefined" && $(element).data("uri") == window.current_file) {
      enable_btn($(element));
    }
    $(element).click(function(e) {
      if ($(element).hasClass("active")) {
        $(e.target).toggleClass("pulsate");
        window.player.paused ? window.player.play() : window.player.pause();
      } else {
        clear_active();
        enable_btn($(e.target));
        load_file($(e.target).data("uri"));
        window.player.play();
        setTimeout(function() {
          reset_btn($(e.target));
        }, Number($(e.target).data("length")) * 1000);
      }
    });
  });
}
