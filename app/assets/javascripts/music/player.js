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
        toggleIcon(element, css.PROCESSING);
        intervals[data.id] = setInterval(function() {
            $.get(data.url, function(response) {
                if (response.stream_url) {
                    toggleIcon(element, css.PROCESSING);
                    clearInterval(intervals[data.id]);
                    window.location = response.stream_url;
                }
            });
        }, 1500);
    }
    function observe() {
        $.each($('.' + css.PLAY_BTN), function(i, element) {
            var data = tracks[parseInt($(element).data('id'))]
            $(element).click(function(e) {
                processing($(element), data);
            });
        });
    }
    $(document).ready(function() {
        observe();
    });
}