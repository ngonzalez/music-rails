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

;(function (window, navigator, $, undefined) {
    "use strict";

    window.ion = window.ion || {};

    if (ion.sound) {
        return;
    }

    ion.sound = function(options) {
        return new Sound(options)
    };

    var AudioContext = window.AudioContext || window.webkitAudioContext,
        audio;

    if (AudioContext) {
        audio = new AudioContext();
    }

    var Sound = function(options) {
        this.options = options;
        this.loaded = false;
        this.autoplay = false;
    };

    Sound.prototype = {

        load: function() {
            if (this.request) return;
            this.request = new XMLHttpRequest();
            this.request.open("GET", this.options.url, true);
            this.request.responseType = "arraybuffer";
            this.request.addEventListener("load", this.ready.bind(this), false);
            this.request.addEventListener("error", this.error.bind(this), false);
            this.request.send();
        },

        ready: function(data) {
            this.request.removeEventListener("load", this.ready.bind(this), false);
            this.request.removeEventListener("error", this.error.bind(this), false);
            audio.decodeAudioData(data.target.response, this.setBuffer.bind(this), this.error.bind(this));
            this.loaded = true;
        },

        setBuffer: function(buffer) {
            this.options.buffer = buffer;
            this.stream = new Stream(this.options);
            if (this.autoplay) {
                this.autoplay = false;
                this.play();
            }
        },

        error: function() {
            console.log('Error decoding audio file')
        },

        play: function(options) {
            if (!this.loaded) {
                this.autoplay = true;
                this.load();
                return;
            }
            this.stream.play();
        },

        stop: function(options) {
            this.stream.stop();
        },

        pause: function(options) {
            this.stream.pause();
        }
    };

    var Stream = function (options) {
        this.buffer = options.buffer;
        this.start = 0;
        this.end = this.buffer.duration;
        this.volume = options.volume || 1;
        this.playing = false;
        this.time_started = 0;
        this.time_ended = 0;
        this.time_offset = 0;
    };

    Stream.prototype = {
        destroy: function() {
            this.stop();
            this.gain && this.gain.disconnect();
            this.source && this.source.disconnect();
        },

        play: function() {
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
            if (typeof this.source.start === "function") {
                this.source.start(0, start, end);
            } else {
                this.source.noteOn(0, start, end);
            }
            this.playing = true;
            this.paused = false;
            this.time_started = new Date().valueOf();
        },

        stop: function() {
            if (this.playing && this.source) {
                if (typeof this.source.stop === "function") {
                    this.source.stop(0);
                } else {
                    this.source.noteOff(0);
                }
            }
            this.clear();
        },

        pause: function() {
            if (this.paused) { this.play(); return; }
            if (!this.playing) return;
            this.source && this.source.stop(0);
            this.paused = true;
        },

        ended: function() {
            this.playing = false;
            this.time_ended = new Date().valueOf();
            this.time_offset += (this.time_ended - this.time_started) / 1000;
            if (this.time_offset >= this.end || this.end - this.time_offset < 0.015) this.clear();
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

} (window, navigator, window.jQuery || window.$));
