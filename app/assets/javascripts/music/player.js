
function observe_btn() {
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
  function enable_player(element, infos) {
    function stop_player() {
      window.player.src = "";
      window.player.currentTime = 0;
    }
    console.log(infos);
    if (element.hasClass("active")) {
      element.toggleClass("pulsate");
      window.player.paused ? window.player.play() : window.player.pause();
    } else {
      if (window.player) {
        clear_active();
        stop_player();
      }
      enable_btn(element);
      window.current_file = infos.id;
      window.player = new Audio(infos.url);
      window.player.play();
      window.player.addEventListener('ended', function() {
        stop_player();
        reset_btn(element);
      }, false);
    }
  }
  var intervals = {};
  $.each($('.play-btn'), function(i, element) {
    if (parseInt($(element).data("id")) == window.current_file) enable_btn($(element));
    if (parseInt($(element).data("stream")) == 0) $(element).addClass("grey");
    $(element).click(function(e) {
      $.get($(element).data("url"), function(response) {
        if (response.url) {
          enable_player($(element), response);
        } else {
          var item_id = parseInt($(element).data("id"));
          if (!intervals[item_id]) {
            processing_btn($(element));
            intervals[item_id] = setInterval(function() {
              $.get($(element).data("url"), function(data) {
                if (data.url) {
                  processing_complete_btn($(element));
                  clearInterval(intervals[item_id]);
                }
              });
            }, 4000);
          }
        }
      });
    });
  });
}