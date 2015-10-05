
function observe_btn() {
  var intervals = {};
  function init_player() {
    $("body").append(
      $(document.createElement("audio"))
                .addClass("hidden")
    );
    return $.extend($("audio").get(0), {
      stop: function() {
        window.player.load_file(null, "");
      },
      load_file: function(id, src) {
        window.current_file = id;
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
  function processing_btn(element) {
    element.hide();
    element.parent().find(".processing").show();
  }
  function processing_complete_btn(element) {
    element.show();
    element.parent().find(".processing").hide();
    element.removeClass("grey");
  }
  function enable_player(element, id, url) {
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
      window.player.load_file(id, url);
      window.player.play();
      setTimeout(function() {
        reset_btn(element);
      }, Number(element.data("length")) * 1000);
    }
  }
  function get_track_infos(url, callback) {
    $.ajax({
      url: url,
      type: "GET",
      success: function(response, textStatus, jqXHR) {
        callback(response);
      },
      error: function(jqXHR, textStatus, errorThrown) {
        console.log(textStatus);
        console.log(errorThrown);
      }
    });
  }
  $.each($('.play-btn'), function(i, element) {
    if ($(element).data("id") == window.current_file) {
      enable_btn($(element));
    }
    if (parseInt($(element).data("stream")) == 0) {
      $(element).addClass("grey");
    }
    $(element).click(function(e) {
      get_track_infos($(element).data("url"), function(response) {
        console.log(response);
        if (response.url) {
          enable_player($(element), response.id, response.url);
        } else {
          var item_id = $(element).data("id");
          if (!intervals[item_id]) {
            processing_btn($(element));
            intervals[item_id] = setInterval(function() {
              get_track_infos($(element).data("url"), function(response) {
                if (response.url) {
                  processing_complete_btn($(element));
                  clearInterval(intervals[item_id]);
                }
              });
            }, 2000);
          }
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