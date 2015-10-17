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
  function init_player() {
    window.player = $.extend(new Audio(), {
      stop: function() {
        window.player.src = "";
        window.player = null;
      },
      load: function(url) {
        $(window.player).append(
          $(document.createElement("source"))
            .attr("src", url)
            .attr("type", "audio/mpeg")
        );
      }
    });
  }
  function enable(element, data) {
    function complete() {
      if (window.player) window.player.stop();
      window.current_file = null;
      clear_active();
    }
    if (element.hasClass("active")) {
      element.toggleClass("pulsate");
      window.player.paused ? window.player.play() : window.player.pause();
    } else {
      complete();
      enable_btn(element);
      init_player();
      window.current_file = data.id;
      window.player.preload = false;
      window.player.load(data.media_url);
      window.player.play();
      window.player.addEventListener("ended", complete);
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