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
        @gain_value = @options.volume || 1
        @time_started = @time_ended = @time_offset = 0

    play: ->
        @playing ? return : @playing = true
        @_play()

    stop: ->
        @_stop() if @playing
        @_clear()

    pause: ->
        @_stop()

    volume: (value) ->
        @gain.gain.value = value;

    _play: ->
        @gain = @audio.createGain()
        @gain.connect @audio.destination
        @source = @audio.createBufferSource()
        @source.buffer = @buffer
        @source.connect @gain
        @source.onended = (event) => @_ended()
        @volume @gain_value
        @start += @time_offset
        @end += @time_offset
        @source.start 0, @start, @end
        @time_started = new Date().valueOf()

    _stop: ->
        @source && @source.stop 0

    _clear: ->
        delete @playing
        @time_offset = 0

    _ended: ->
        delete @playing
        @time_ended = new Date().valueOf()
        @time_offset += (@time_ended - @time_started) / 1000
        if (@time_offset >= @end) || (@end - @time_offset < 0.015)
            @gain.disconnect()
            @source.disconnect()
            @_clear()
            @callback() if @callback
