
((AudioContext) ->
    audio = new AudioContext()
    window.new_player = (options, init, complete) ->
        $.getNative(options.url).then (data) ->
            audio.decodeAudioData data, (buffer) ->
                new Stream audio, buffer, options, init, complete
)(window.AudioContext || window.webkitAudioContext)

class Stream
    constructor: (@audio, @buffer, @options, @init, @complete) ->
        @time = 0
        @paused = false
        @init @

    play: ->
        @playing = true
        @_play()

    stop: ->
        @source.stop() if @playing

    pause: ->
        @paused = true
        @time += @_playback_time()
        @source.stop 0

    volume: (value) ->
        @_volume value

    _playback_time: ->
        return @time if !@started_at
        return (Date.now() - @started_at) / 1000

    _play: ->
        @gain = @audio.createGain()
        @gain.connect @audio.destination
        @source = @audio.createBufferSource()
        @source.buffer = @buffer
        @source.connect @gain
        @source.onended = (event) => @_ended()
        @_volume @options.volume || 1
        @paused = false ; @started_at = Date.now()
        @source.start 0, @time, @buffer.duration

    _volume: (value) ->
        @gain.gain.value = value;

    _ended: ->
        return if @paused
        delete @playing
        @complete() if @complete
        @gain.disconnect()
        @source.disconnect()
