var xhr_requests = [];
function init_players(streams_path, tracks, css) {
    function testStream(track_id, callback) {
        var x = 0;
        var data = { track_id: track_id };
        var intervalID = setInterval(function () {
            xhr_requests.push(
                $.ajax({
                    url: streams_path,
                    data: data,
                    type: 'POST',
                    dataType: 'json',
                    success: function(response) {
                        if (response.stream_uuid) {
                            data['stream_uuid'] = response.stream_uuid;
                        } else if (response.stream_url) {
                            clearInterval(intervalID);
                            callback({ stream_url: response.stream_url });
                        }
                    }
                })
            )
            if (++x === 10) {
                clearInterval(intervalID);
                callback({ error: 'TIMEOUT' });
            }
        }, 2000);
    }
    function hasIcon(element, className) {
        return element.parent().find('.' + className).is(':visible');
    }
    function toggleIcon(element, className) {
        hasIcon(element, className) ? element.show() : element.hide();
        element.parent().find('.' + className).toggleClass(css.HIDDEN);
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
        testStream(element.data('id'), function(response) {
            if (response.error) {
                toggleIcon(element, css.BUFFERING);
            } else {
              toggleIcon(element, css.BUFFERING);
              window.location = response.stream_url;
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
            if (!data.media_url) $(element).addClass(css.DISABLED);
            $(element).click(function(e) {
                window.current_file = data.id;
                $.each(xhr_requests, function(i, xhr_request) {
                    xhr_request.abort();
                });
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