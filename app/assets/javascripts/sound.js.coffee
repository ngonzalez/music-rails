((AudioContext) ->
    window.audio = window.set_ios_callbacks new AudioContext()
    window.new_player = (options, init, complete) ->
        xhr = new XMLHttpRequest()
        xhr.open 'GET', options.url, true
        xhr.responseType = 'arraybuffer'
        xhr.onload = (event) =>
            window.audio.decodeAudioData xhr.response, (buffer) ->
                init(new Stream(buffer, options, complete))
        xhr.send()
)(window.AudioContext || window.webkitAudioContext)

class Stream
    constructor: (@buffer, @options, @complete) ->
        @time = 0
        @paused = false

    play: ->
        @playing = true
        @_play()

    stop: ->
        delete @paused if @paused
        @time = 0
        @_stop()

    pause: ->
        @paused = true
        @time += @_playback_time()
        @_stop()

    volume: (value) ->
        @_volume value

    _volume: (value) ->
        @node.gain.value = value;
        return true

    _playback_time: ->
        return @time if !@started_at
        return (Date.now() - @started_at) / 1000

    _play: ->
        @node = window.audio.createGain()
        @node.connect window.audio.destination
        @source = window.audio.createBufferSource()
        @source.buffer = @buffer
        @source.connect @node
        @source.onended = (event) => @_ended()
        @_volume @options.volume || 1
        @paused = false
        @started_at = Date.now()
        @source.start 0, @time, @buffer.duration
        return true

    _stop: ->
        if @playing
            try
                @source.stop 0
                return true
            catch e
                @_ended()
        else
            @_ended()

    _ended: ->
        return if @paused
        delete @playing if @playing
        @complete() if @complete
        @node && @node.disconnect()
        @source && @source.disconnect()
        return true
