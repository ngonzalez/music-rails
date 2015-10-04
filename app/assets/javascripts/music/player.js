
function observe_btn() {
  var interval_id;
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
    element.addClass("fa-play-circle");
    element.removeClass("active");
  }
  function enable_btn(element) {
    element.addClass("fa-pause");
    element.removeClass("fa-play-circle");
    element.addClass("active");
  }
  function enable_player(element) {
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
      window.player.load_file(element.data("uri"));
      window.player.play();
      setTimeout(function() {
        reset_btn(element);
      }, Number(element.data("length")) * 1000);
    }
  }
  function check_for_track(element) {
    $.ajax({
      url: element.data("url"),
      type: "GET",
      success: function(response, textStatus, jqXHR) {
        console.log(response);
        if (response.url) {
          clearInterval(interval_id);
          element.data("uri", response.url);
          enable_player($(element));
        }
      }
    });
  }
  $.each($('.play-btn'), function(i, element) {
    if ($(element).data("uri") == window.current_file) enable_btn($(element));
    $(element).click(function(e) {
      $.ajax({
        url: $(element).data("url"),
        type: "GET",
        success: function(response, textStatus, jqXHR) {
          console.log(response);
          if (response.url) {
            $(element).data("uri", response.url);
            enable_player($(element));
          } else if (!interval_id) {
            interval_id = setInterval(function() {
              check_for_track($(element));
            }, 5000);
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
