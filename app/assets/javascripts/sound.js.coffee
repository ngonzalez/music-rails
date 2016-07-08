
((AudioContext) ->
    audio = new AudioContext()
    window.new_player = (options, init_callback, complete_callback) ->
        $.getNative(options.url).then (data) ->
            audio.decodeAudioData data, (buffer) ->
                new Stream audio, buffer, options, init_callback, complete_callback

)(window.AudioContext || window.webkitAudioContext)

class Stream
    constructor: (@audio, @buffer, @options, @init, @complete) ->
        @init @

    play: ->
        return if @playing
        @playing = true
        @_play()

    stop: ->
        @source.stop() if @playing

    volume: (value) ->
        @_volume value

    _play: ->
        @gain = @audio.createGain()
        @gain.connect @audio.destination
        @source = @audio.createBufferSource()
        @source.buffer = @buffer
        @source.connect @gain
        @source.onended = (event) => @_ended()
        @_volume @options.volume || 1
        @source.start 0, 0, @buffer.duration

    _volume: (value) ->
        @gain.gain.value = value;

    _ended: ->
        delete @playing
        @_reset()

    _reset: ->
        @complete() if @complete
        @gain && @gain.disconnect()
        @source && @source.disconnect()
