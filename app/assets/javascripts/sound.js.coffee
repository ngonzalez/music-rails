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
        @volume ||= 1
        @playing = false
        @time_started = @time_ended = @time_offset = 0

    play: ->
        return if @playing
        @gain = @audio.createGain()
        @source = @audio.createBufferSource()
        @source.buffer = @buffer
        @source.connect @gain
        @gain.connect @audio.destination
        @gain.gain.value = @volume
        @source.onended = (event) => @_ended()
        @start += @time_offset
        @end += @time_offset
        @source.start 0, @start, @end
        @playing = true
        @paused = false
        @time_started = new Date().valueOf()

    stop: ->
        @source && @source.stop 0 if @playing
        @_clear()

    pause: ->
        @source && @source.stop 0 
        @paused = true

    setVolume: (value) ->
        @gain.gain.value = value;

    _ended: ->
        @playing = false
        @time_ended = new Date().valueOf()
        @time_offset += (@time_ended - @time_started) / 1000
        if @time_offset >= @end || @end - @time_offset < 0.015
            @callback() if @callback
            @destroy()
            @_clear()

    _clear: ->
        @time_offset = 0
        @paused = false
        @playing = false
