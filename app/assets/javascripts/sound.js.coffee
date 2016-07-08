
((AudioContext) ->
    audio = new AudioContext()
    window.new_player = (options, init_callback, complete_callback) ->
        $.getNative(options.url).then (data) ->
            audio.decodeAudioData data, (buffer) ->
                new Stream audio, buffer, options, init_callback, complete_callback

)(window.AudioContext || window.webkitAudioContext)

class Stream
    constructor: (@audio, @buffer, @options, @init, @complete) ->
        @_set_values()
        @init @

    play: ->
        return if @playing
        @playing = true
        @pause_duration += new Date().valueOf() - @paused_at if @paused_at
        @_play()

    stop: ->
        @source.stop() if @playing
        delete @playing

    pause: ->
        @paused_at = new Date().valueOf()
        @source.stop()

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

    _volume: (value) ->
        @gain.gain.value = value;

    _set_values: ->
        @end = @buffer.duration
        @gain_value = @options.volume || 1
        @start = @paused_at = @pause_duration = @time_offset = 0

    _ended: ->
        delete @playing
        @time_offset += new Date().valueOf() - @time_started
        @time_remaining = @buffer.duration - ((@time_offset + @pause_duration) / 1000)
        @_reset() if parseInt(@time_remaining) <= 0

    _reset: ->
        @_set_values()
        @complete() if @complete
        @gain && @gain.disconnect()
        @source && @source.disconnect()
