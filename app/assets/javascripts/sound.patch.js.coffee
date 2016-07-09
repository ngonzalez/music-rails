window.set_ios_callbacks = (audio) ->
    cb = () =>
        buffer = audio.createBuffer 1, 1, 22050
        source = audio.createBufferSource()
        source.buffer = buffer
        source.connect audio.destination
        source.start 0
        window.removeEventListener 'touchstart', cb, false
    window.addEventListener 'touchstart', cb, false
    return audio

window.trigger_ios_callbacks = () ->
    event = document.createEvent 'Event'
    event.initEvent 'touchstart', true, true
    window.dispatchEvent event

