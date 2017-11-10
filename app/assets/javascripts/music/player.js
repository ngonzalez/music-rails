function init_players(streams_path, tracks, css) {
    function initPlayer(data, url, loaded, complete) {
        $('video').remove();
        $('<video />', { id: 'video_' + data.id, controls: true }).appendTo($('body'));
        var player = document.getElementById('video_' + data.id);
        if (typeof hls !== 'undefined') hls.destroy();
        window.hls = new Hls();
        hls.loadSource(url);
        hls.attachMedia(player);
        player.load();
        player.volume = 0.5;
        player.addEventListener('progress', function() {
            if (!data.buffered && player.buffered.end(0) > 10) {
                data.buffered = true;
                loaded(player);
            }
        });
        hls.on(Hls.Events.ERROR, function(event, data) {
            switch(data.type) {
                case Hls.ErrorTypes.MEDIA_ERROR:
                    if (data.details == Hls.ErrorDetails.BUFFER_STALLED_ERROR) {
                        delete data.buffered;
                        if (typeof hls !== 'undefined') hls.destroy();
                        complete(player);
                    }
                    break;
            }
        });
    }
    function testStream(url, callback) {
        $.get(url, function(response) {
            var x = 0;
            var intervalID = setInterval(function () {
                $.ajax({
                    url: streams_path,
                    data: { stream_uuid: response.stream_uuid },
                    type: 'POST',
                    dataType: 'json',
                    success: function(response) {
                        if (response.stream_url) {
                            clearInterval(intervalID);
                            callback({ stream_url: response.stream_url });
                        }
                    }
                });
                if (++x === 10) {
                    clearInterval(intervalID);
                    callback({ error: 'TIMEOUT' });
                }
            }, 2000);
        });
    }
    function hasIcon(element, className) {
        return element.parent().find('.' + className).is(':visible');
    }
    function toggleIcon(element, className) {
        hasIcon(element, className) ? element.show() : element.hide();
        element.parent().find('.' + className).toggleClass(css.HIDDEN);
    }
    function toggleActive(element) {
        element.toggleClass(css.ACTIVE);
    }
    function resetBtns() {
        $.each($('.play-btn'), function(i, element) {
            if (parseInt($(element).data('id')) != window.current_file)
                if ($(element).hasClass(css.ACTIVE))
                    $(element).removeClass(css.ACTIVE)
                if (hasIcon($(element), css.BUFFERING))
                    toggleIcon($(element), css.BUFFERING);
                    $(element).show();
        });
    }
    function enable(element, data) {
        resetBtns();
        toggleIcon(element, css.BUFFERING);
        testStream(element.data('url'), function(response) {
            if (response.error) {
                toggleIcon(element, css.BUFFERING);
            } else {
                if (Hls.isSupported()) {
                    initPlayer(data, response.stream_url, function(player) {
                        toggleIcon(element, css.BUFFERING);
                        toggleActive(element);
                        player.play();
                    }, function(player) {
                        toggleActive(element);
                        if (window.current_file == data.id)
                            window.current_file = null;
                    });
                } else {
                    toggleIcon(element, css.BUFFERING);
                    window.location = response.stream_url;
                }
            }
        });
    }
    var intervals = {};
    function processing(element, data) {
        if (!intervals[data.id]) {
            toggleIcon(element, css.PROCESSING);
            intervals[data.id] = setInterval(function() {
                $.get(data.url, function(response) {
                    if (response.media_url) {
                        tracks[data.id].media_url = response.media_url;
                        toggleIcon(element, css.PROCESSING);
                        clearInterval(intervals[data.id]);
                        $(element).removeClass(css.DISABLED);
                        if (window.current_file == data.id)
                            enable(element, data);
                    }
                });
            }, 2000);
        }
    }
    function observe() {
        if (!tracks) return;
        $.each($('.play-btn'), function(i, element) {
            var data = tracks[parseInt($(element).data('id'))]
            if (!data) return;
            if (!data.media_url) $(element).addClass(css.DISABLED);
            if (window.current_file == data.id) toggleActive($(element));
            $(element).click(function(e) {
                if ($(element).hasClass(css.ACTIVE) ||
                    $(element).hasClass(css.PROCESSING) ||
                    $(element).hasClass(css.BUFFERING)) {
                    $(element).toggleClass('pulsate');
                    return;
                }
                window.current_file = data.id;
                if (data.media_url) {
                    enable($(element), data);
                } else {
                    processing($(element), data);
                }
            });
        });
    }
    $(document).ready(function() {
        observe();
    });
}