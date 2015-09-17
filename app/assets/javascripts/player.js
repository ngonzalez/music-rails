
function observePlayers() {

  function pausePlayer() {
    if (typeof AV != "undefined") {
      if (window.player) {
        window.player.stop();
        window.player = undefined;
      }
    } else if ($("audio").length > 0) {
      $($("audio").get(0)).stop();
      $($("audio").get(0)).attr("src", "");
    }
  }

  function playFile(file_uri) {
    if (typeof AV != "undefined") {
      pausePlayer();
      window["player"] = AV.Player.fromURL(file_uri)
      window.player.play();
    } else {
      if ($("audio").length > 0) {
        pausePlayer();
        $($("audio").get(0)).attr("src", file_uri);
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

  $(".fa-play-circle").unbind("click");
  $(".fa-play-circle").click(function(e) {
    $.each($(".fa-pause"), function(i, element) {
      $(element).removeClass("fa-pause");
      $(element).addClass("fa-play-circle");
    });
    $(e.target).removeClass("fa-play-circle");
    $(e.target).addClass("fa-pause");
    playFile($(e.target).data("uri"));
    observePlayers();
  });

  $(".fa-pause").unbind("click");
  $(".fa-pause").click(function(e) {
    $(e.target).removeClass("fa-pause");
    $(e.target).addClass("fa-play-circle");
    pausePlayer();
    observePlayers();
  });
  
}
