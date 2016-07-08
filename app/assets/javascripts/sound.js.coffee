((AudioContext) ->
    audio = new AudioContext()
    window.new_player = (options, callback) ->
        $.getNative(options.url).then (data) ->
            audio.decodeAudioData data, (buffer) ->
                window.player = new Stream audio, buffer, options, callback
                window.player.play()
)(window.AudioContext || window.webkitAudioContext)

class Stream
    constructor: (@audio, @buffer, @options, @callback) ->
        @start = 0
        @end = @buffer.duration
        @volume = @options.volume || 1
        @time_started = @time_ended = @time_offset = 0

    play: ->
        @playing ? return : @playing = true
        @_set_source()
        @start += @time_offset
        @end += @time_offset
        @source.start 0, @start, @end
        @time_started = new Date().valueOf()

    stop: ->
        @_stop() if @playing
        @_clear()

    pause: ->
        @_stop()

    volume: (value) ->
        @gain.gain.value = value;

    _set_source: ->
        @gain = @audio.createGain()
        @source = @audio.createBufferSource()
        @source.buffer = @buffer
        @source.connect @gain
        @gain.connect @audio.destination
        @gain.gain.value = @volume
        @source.onended = (event) => @_ended()

    _destroy: ->
        @gain && @gain.disconnect()
        @source && @source.disconnect()

    _stop: ->
        @source && @source.stop 0

    _clear: ->
        delete @playing
        @time_offset = 0

    _ended: ->
        delete @playing
        @time_ended = new Date().valueOf()
        @time_offset += (@time_ended - @time_started) / 1000
        if @time_offset >= @end || @end - @time_offset < 0.015
            @callback() if @callback
            @_destroy()
            @_clear()
