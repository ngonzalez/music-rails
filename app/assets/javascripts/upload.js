(function($) {
    $(function() {

        window[ 'send_file' ] = function(options) {
          
            var control = $("#" + options.input_id);

            var files = document.getElementById(options.input_id).files;

            function post_data(data, callback) {
                $.ajax({
                    url: options.url,
                    type: options.type,
                    processData: false,
                    contentType: false,
                    data: data,
                    success: function(response, textStatus, jqXHR) {
                        callback(response);
                    },
                    error: function(jqXHR, textStatus, errorThrown) {
                        options.error(textStatus, errorThrown);
                    }
                });
            }

            function set_params(result, data, file, callback) {
                data.append(options.name, file);
                if (options.params) {
                    $.each(options.params, function(k, v) {
                        data.append(k, v);
                    });
                }
                callback();
            }

            if (!options.counter) options.counter = 0;

            if (options.counter < files.length) {

                var file = files[options.counter];

                options.counter++;

                var data = new FormData();
                var file_type = file.name.replace(/^.*\./, '').toLowerCase();
                var reader = new FileReader();

                reader.onload = (function(f) {
                    return function(e) {
                        set_params(e.target.result, data, file, function() {
                            if (!options.extensions || (options.extensions && $.inArray(file_type, options.extensions))) {
                                post_data(data, function(response) {
                                    if (options.progress) {
                                        options.progress({
                                            counter: options.counter,
                                            total_files: files.length,
                                            response: response
                                        });
                                    }
                                    send_file(options);
                                });
                            } else if (options.complete) {
                                options.complete();
                            }
                        });
                    };
                })(file);

                reader.readAsDataURL(file);

            } else {

                if (window.navigator.userAgent.indexOf("MSIE") > 0) {
                    setTimeout(function() {
                        control.replaceWith(control = control.clone(true));
                    }, 1000);
                } else {
                    control.val('');
                }

                if (options.complete) options.complete();

            }
        }

    });
})(jQuery);