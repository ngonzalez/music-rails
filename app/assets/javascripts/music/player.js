
function observe_btn() {
  var intervals = {};
  function init_player() {
    $("body").append(
      $(document.createElement("audio"))
                .addClass("hidden")
    );
    return $.extend($("audio").get(0), {
      stop: function() {
        window.player.load_file("");
      },
      load_file: function(src) {
        window.current_file = src;
        $(window.player).attr("src", src);
      }
    });
  }
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
  function enable_player(element, url) {
    if (element.hasClass("active")) {
      element.toggleClass("pulsate");
      window.player.paused ? window.player.play() : window.player.pause();
    } else {
      if (window.player) {
        window.player.stop();
        clear_active();
      } else {
        window.player = init_player();
      }
      enable_btn(element);
      window.player.load_file(url);
      window.player.play();
      setTimeout(function() {
        reset_btn(element);
      }, Number(element.data("length")) * 1000);
    }
  }
  function check_for_track(element, callback) {
    $.ajax({
      url: element.data("url"),
      type: "GET",
      success: function(response, textStatus, jqXHR) {
        if (response.url) {
          element.show();
          element.parent().find(".processing").hide();
          $(element).removeClass("grey");
          callback();
        }
      }
    });
  }
  $.each($('.play-btn'), function(i, element) {
    if ($(element).data("uri") == window.current_file) {
      enable_btn($(element));
    }
    if (parseInt($(element).data("stream")) == 0) {
      $(element).addClass("grey");
    }
    $(element).click(function(e) {
      $.ajax({
        url: $(element).data("url"),
        type: "GET",
        success: function(response, textStatus, jqXHR) {
          if (response.url) {
            enable_player($(element), response.url);
          } else {
            var item_id = $(element).data("id");
            if (!intervals[item_id]) {
              $(element).hide();
              $(element).parent().find(".processing").show();
              intervals[item_id] = setInterval(function() {
                check_for_track($(element), function() {
                  clearInterval(intervals[item_id]);
                });
              }, 2000);
            }
          }
        },
        error: function(jqXHR, textStatus, errorThrown) {
          console.log(textStatus);
          console.log(errorThrown);
        }
      });
    });
  });
  $(window).bind('beforeunload', function() {
    if (window.player) {
      window.player.stop();
      window.player = "undefined";
    }
  });
}