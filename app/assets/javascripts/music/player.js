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
  function enable(element, infos) {
    if (element.hasClass("active")) {
      element.toggleClass("pulsate");
      window.player.paused ? window.player.play() : window.player.pause();
    } else {
      if (window.player) {
        window.player.src = "";
        window.player = undefined;
        clear_active();
      }
      enable_btn(element);
      window.current_file = infos.id;
      window.player = new Audio(infos.url);
      window.player.play();
      window.player.addEventListener("ended", function() {
        window.player.src = "";
        window.player = undefined;
        reset_btn(element);
      }, false);
    }
  }
  function loading(element) {
    var item_id = parseInt($(element).data("id"));
    if (!intervals[item_id]) {
      processing_btn(element);
      intervals[item_id] = setInterval(function() {
        $.get(element.data("url"), function(response) {
          if (response.url) {
            tracks[item_id] = response.url;
            processing_complete_btn(element);
            clearInterval(intervals[item_id]);
          }
        });
      }, 2500);
    }
  }
  function observe() {
    $.each($(".play-btn"), function(i, element) {
      var track_id = $(element).data("id");
      if (!tracks[track_id]) $(element).addClass("grey");
      if (parseInt($(element).data("id")) == window.current_file) enable_btn($(element));
      $(element).click(function(e) {
        if (tracks[track_id]) {
          enable($(element), { id: track_id, url: tracks[track_id] });
        } else {
          loading($(element));
        }
      });
    });
  }
  observe();
}