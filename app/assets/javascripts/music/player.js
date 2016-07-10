function init_players(tracks, browser) {
  function enable(element, data) {
    function toggle_btn(element) {
      element.toggleClass('fa-pause');
      element.toggleClass('fa-play');
      element.toggleClass('active');
    }
    if (element.hasClass('active')) {
        element.toggleClass('pulsate');
        window.player.paused ? window.player.play() : window.player.pause();
    } else if (!$(element).hasClass('text-muted')) {
        toggle_btn(element);
        $(element).addClass('text-muted')
        if (window.player) window.player.stop();
        new_player({
            volume: 0.5,
            url: document.location.protocol + '//' + document.location.host + data.media_url
        }, function(player) {
            window.trigger_ios_callbacks();
            window.current_file = data.id;
            window.player = player;
            window.player.play();
            $(element).removeClass('text-muted');
        }, function() {
            window.current_file = null;
            element.removeClass('pulsate');
            toggle_btn(element);
        })
    }
  }
  var intervals = {};
  function loading(element, data) {
    function toggle_btn(element) {
      element.toggle();
      element.parent().find('.processing').toggleClass('hidden');
      element.toggleClass('grey');
    }
    if (!intervals[data.id]) {
      toggle_btn(element);
      intervals[data.id] = setInterval(function() {
        $.get(data.url, function(response) {
          if (response.media_url) {
            tracks[data.id].media_url = response.media_url;
            toggle_btn(element);
            clearInterval(intervals[data.id]);
          }
        });
      }, 2500);
    }
  }
  function observe() {
    if (!tracks) return;
    $.each($('.play-btn'), function(i, element) {
      var data = tracks[parseInt($(element).data('id'))]
      if (!data) return;
      if (!data.media_url) $(element).addClass('grey');
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