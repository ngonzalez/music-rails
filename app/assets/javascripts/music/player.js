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
    element.parent().find(".processing").show();
  }
  function processing_complete_btn(element) {
    element.show();
    element.parent().find(".processing").hide();
    element.removeClass("grey");
  }
  function get_data(element) {
    return tracks[parseInt(element.data("id"))];
  }
  function enable(element, data) {
    function stop_player() {
      window.player.src = "";
      window.player = undefined;
    }
    if (element.hasClass("active")) {
      element.toggleClass("pulsate");
      window.player.paused ? window.player.play() : window.player.pause();
    } else {
      if (window.player) {
        stop_player();
        clear_active();
      }
      enable_btn(element);
      window.current_file = data.id;
      window.player = new Audio(data.media_url);
      window.player.play();
      window.player.addEventListener("ended", function() {
        stop_player();
        reset_btn(element);
      }, false);
    }
  }
  function loading(element, data) {
    if (!intervals[data.id]) {
      processing_btn(element);
      intervals[data.id] = setInterval(function() {
        $.get(data.url, function(response) {
          if (response.url) {
            tracks[data.id].media_url = response.url;
            processing_complete_btn(element);
            clearInterval(intervals[data.id]);
          }
        });
      }, 2500);
    }
  }
  function observe() {
    $.each($(".play-btn"), function(i, element) {
      var data = get_data($(element));
      if (!data.media_url) $(element).addClass("grey");
      if (window.current_file == data.id) enable_btn($(element));
      $(element).click(function(e) {
        data.media_url ? enable($(element), data) : loading($(element), data);
      });
    });
  }
  observe();
}