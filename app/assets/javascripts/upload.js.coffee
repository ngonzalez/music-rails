(($) ->
    $.widget 'ui.sendFilesProxy',
        send: (options) ->
            options.counter = 0 if !options.counter
            @files = document.getElementById(@.element.attr('id')).files
            if options.counter < @files.length
                reader = new FileReader()
                file = @files[options.counter]
                reader.onload = (event) => @_send_file new FormData(), event.target.result, file, options
                reader.readAsDataURL file
                options.counter++
            else
                @.element.val ''
                options.complete() if options.complete
        _send_file: (data, result, file, options) ->
            if !options.extensions || $.inArray(name.replace(/^.*\./, '').toLowerCase(), options.extensions)
                @_post_data @_set_params(data, file, options), options, (response) =>
                    options.progress response: response, counter: options.counter, total_files: @files.length if options.progress
                    @send options
            else if options.complete
                options.complete()
        _set_params: (data, file, options) ->
            data.append options.name, file
            if options.params
                $.each options.params, (k, v) ->
                    data.append k, v
            return data
        _post_data: (data, options, callback) ->
            $.ajax
                url: options.url,
                type: options.type,
                data: data,
                processData: false,
                contentType: false,
                success: callback

    $(document).ready ->
        $.each $('input[type=file]'), (i, element) ->
            $(element).sendFilesProxy()

)(jQuery)
