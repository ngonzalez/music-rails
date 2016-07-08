
((AudioContext) ->
    audio = new AudioContext()
    window.new_player = (options, init_callback, complete_callback) ->
        $.getNative(options.url).then (data) ->
            audio.decodeAudioData data, (buffer) ->
                new Stream audio, buffer, options, init_callback, complete_callback

)(window.AudioContext || window.webkitAudioContext)

class Stream
    constructor: (@audio, @buffer, @options, @init, @complete) ->
        @start = 0
        @end = @buffer.duration
        @gain_value = @options.volume || 1
        @time_offset = 0
        @init @

    play: ->
        return if @playing
        @playing = true
        @_play()

    stop: ->
        @_stop() if @playing
        @_clear()

    pause: ->
        @_stop()

    volume: (value) ->
        @_volume value

    _play: ->
        @gain = @audio.createGain()
        @gain.connect @audio.destination
        @source = @audio.createBufferSource()
        @source.buffer = @buffer
        @source.connect @gain
        @source.onended = (event) => @_ended()
        @_volume @gain_value
        @start += @time_offset / 1000
        @end += @time_offset / 1000
        @time_started = new Date().valueOf()
        @source.start 0, @start, @end

    _stop: ->
        @source && @source.stop 0

    _volume: (value) ->
        @gain.gain.value = value;

    _clear: ->
        delete @playing
        @time_offset = 0

    _ended: ->
        delete @playing
        @time_offset += new Date().valueOf() - @time_started
        if (@buffer.duration - @audio.currentTime) < 0.5
            @_clear()
            @complete() if @complete
            @gain && @gain.disconnect()
            @source && @source.disconnect()
