/**
 * Ion.Sound
 * version 3.0.7 Build 89
 * © Denis Ineshin, 2016
 *
 * Project page:    http://ionden.com/a/plugins/ion.sound/en.html
 * GitHub page:     https://github.com/IonDen/ion.sound
 *
 * Released under MIT licence:
 * http://ionden.com/a/plugins/licence-en.html
 */

;(function(window, navigator, $, AudioContext) {
    "use strict";

    var audio = new AudioContext();

    // window.new_player = function(options, callback) {
    //     $.getNative(options.url).then(function(data) {
    //         audio.decodeAudioData(data, function(buffer) {
    //             window.player = new Stream(buffer, options, callback);
    //             window.player.play();
    //         });
    //     });
    // }

    var Stream = function(buffer, options, callback) {
        this.buffer = buffer;
        this.start = 0;
        this.end = this.buffer.duration;
        this.volume = options.volume || 1;
        this.playing = false;
        this.time_started = 0;
        this.time_ended = 0;
        this.time_offset = 0;
        this.callback = callback;
    };

    Stream.prototype = {
        destroy: function() {
            this.gain && this.gain.disconnect();
            this.source && this.source.disconnect();
        },

        play: function(callback) {
            if (this.playing) return;
            this.gain = audio.createGain();
            this.source = audio.createBufferSource();
            this.source.buffer = this.buffer;
            this.source.connect(this.gain);
            this.gain.connect(audio.destination);
            this.gain.gain.value = this.volume;
            this.source.onended = this.ended.bind(this);
            this._play();
        },

        _play: function() {
            var start, end;
            start = this.start + this.time_offset;
            end = this.end - this.time_offset;
            this.source.start(0, start, end);
            this.playing = true;
            this.paused = false;
            this.time_started = new Date().valueOf();
        },

        stop: function() {
            if (this.playing) this.source.stop(0);
            this.clear();
        },

        pause: function() {
            this.source && this.source.stop(0);
            this.paused = true;
        },

        ended: function() {
            this.playing = false;
            this.time_ended = new Date().valueOf();
            this.time_offset += (this.time_ended - this.time_started) / 1000;
            if (this.time_offset >= this.end || this.end - this.time_offset < 0.015) {
                if (this.callback) this.callback();
                this.destroy();
                this.clear();
            }
        },

        clear: function() {
            this.time_offset = 0;
            this.paused = false;
            this.playing = false;
        },

        setVolume: function(value) {
            this.gain.gain.value = value;
        }
    };

} (window, navigator, window.jQuery || window.$, window.AudioContext || window.webkitAudioContext));
