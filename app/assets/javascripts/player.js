
function pausePlayer() {
  if (typeof AV != "undefined") {
    if (window.player) {
      window.player.stop();
      window.player = undefined;
    }
  } else if ($("audio").length > 0) {
    $("audio").attr("src", "");
  }
}

function playFile(file_uri) {
  window["current_file"] = file_uri;
  if (typeof AV != "undefined") {
    pausePlayer();
    window["player"] = AV.Player.fromURL(file_uri);
    window.player.play();
  } else {
    if ($("audio").length > 0) {
      pausePlayer();
      $("audio").attr("src", file_uri);
      $("audio").get(0).play();
    } else {
      $("body").append(
        $(document.createElement("audio"))
                  .attr("src", file_uri)
                  .addClass("hidden")
      );
      $("audio").get(0).play();
    }
  }
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
function observe_btn() {
  $.each($('.play-btn'), function(i, btn) {
    if (typeof(window.current_file) != "undefined" && $(btn).data("uri") == window.current_file) {
      enable_btn($(btn));
    }
    $(btn).click(function(e) {
      if ($(btn).hasClass("active")) {
        reset_btn($(e.target));
        pausePlayer();
      } else {
        $.each($(".play-btn.active"), function(i, element) {
          reset_btn($(element));
        });
        enable_btn($(e.target));
        playFile($(e.target).data("uri"));
        setTimeout(function() {
          reset_btn($(e.target));
        }, Number($(e.target).data("length")) * 1000);
      }
    });
  });
}
