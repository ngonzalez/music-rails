function init_players(tracks, css) {
    function hasIcon(element, className) {
        return element.parent().find('.' + className).is(':visible');
    }
    function toggleIcon(element, className) {
        hasIcon(element, className) ? element.show() : element.hide();
        element.parent().find('.' + className).toggleClass(css.HIDDEN);
    }
    var intervals = {};
    function processing(element, data) {
        if (!intervals[data.id]) {
            toggleIcon(element, css.PROCESSING);
            intervals[data.id] = setInterval(function() {
                $.get(data.url, function(response) {
                    if (response.stream_url) {
                        tracks[data.id].stream_url = response.stream_url;
                        toggleIcon(element, css.PROCESSING);
                        clearInterval(intervals[data.id]);
                        window.location = response.stream_url;
                    }
                });
            }, 2000);
        }
    }
    function observe() {
        if (!tracks) return;
        $.each($('.play-btn'), function(i, element) {
            var data = tracks[parseInt($(element).data('id'))]
            $(element).click(function(e) {
                window.current_file = data.id;
                if (data.stream_url) {
                    window.location = data.stream_url;
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