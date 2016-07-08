﻿/**
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

    var Sound = function (options) {
        this.options = options;
        this.url = options.url;

        this.request = null;
        this.stream = null;
        this.result = {};

        this.loaded = false;
        this.decoded = false;
        this.no_file = false;
        this.autoplay = false;
    };

    Sound.prototype = {
        init: function (options) {
            if (this.options.preload) {
                this.load();
            }
        },

        destroy: function () {
            this.stream.destroy();
            this.stream = null;
            this.result = null;
            this.options.buffer = null;
            this.options = null;

            if (this.request) {
                this.request.removeEventListener("load", this.ready.bind(this), false);
                this.request.removeEventListener("error", this.error.bind(this), false);
                this.request.abort();
                this.request = null;
            }
        },

        load: function () {
            if (this.no_file) {
                return;
            }
            if (this.request) {
                return;
            }
            this.request = new XMLHttpRequest();
            this.request.open("GET", this.url, true);
            this.request.responseType = "arraybuffer";
            this.request.addEventListener("load", this.ready.bind(this), false);
            this.request.addEventListener("error", this.error.bind(this), false);

            this.request.send();
        },

        reload: function () {
            this.load();
        },

        ready: function (data) {
            this.result = data.target;
            if (this.result.readyState !== 4) {
                this.reload();
                return;
            }
            if (this.result.status !== 200 && this.result.status !== 0) {
                this.reload();
                return;
            }
            this.request.removeEventListener("load", this.ready.bind(this), false);
            this.request.removeEventListener("error", this.error.bind(this), false);
            this.request = null;
            this.loaded = true;
            this.decode();
        },

        decode: function () {
            if (!audio) {
                return;
            }

            audio.decodeAudioData(this.result.response, this.setBuffer.bind(this), this.error.bind(this));
        },

        setBuffer: function (buffer) {
            this.options.buffer = buffer;
            this.decoded = true;

            var config = {
                name: this.options.name,
                alias: this.options.alias,
                duration: this.options.buffer.duration
            };

            if (this.options.ready_callback && typeof this.options.ready_callback === "function") {
                this.options.ready_callback.call(this.options.scope, config);
            }

            this.stream = new Stream(this.options);

            if (this.autoplay) {
                this.autoplay = false;
                this.play();
            }
        },

        error: function () {
            this.reload();
        },

        play: function (options) {
            if (!this.loaded) {
                this.autoplay = true;
                this.load();

                return;
            }

            if (this.no_file || !this.decoded) {
                return;
            }
            this.stream.play(this.options);
        },

        stop: function (options) {
            this.stream.stop();
        },

        pause: function (options) {
            this.stream.pause();
        },

        volume: function (options) {
            this.stream.setVolume(this.options);
        }
    };

    var Stream = function (options) {
        this.alias = options.alias;
        this.name = options.name;

        this.buffer = options.buffer;
        this.start = options.start || 0;
        this.end = options.end || this.buffer.duration;
        this.multiplay = options.multiplay || false;
        this.volume = options.volume || 1;
        this.scope = options.scope;
        this.ended_callback = options.ended_callback;

        this.setLoop(options);

        this.source = null;
        this.gain = null;
        this.playing = false;
        this.paused = false;

        this.time_started = 0;
        this.time_ended = 0;
        this.time_played = 0;
        this.time_offset = 0;
    };

    Stream.prototype = {
        destroy: function () {
            this.stop();

            this.buffer = null;
            this.source = null;

            this.gain && this.gain.disconnect();
            this.source && this.source.disconnect();
            this.gain = null;
            this.source = null;
        },

        setLoop: function (options) {
            if (options.loop === true) {
                this.loop = 9999999;
            } else if (typeof options.loop === "number") {
                this.loop = +options.loop - 1;
            } else {
                this.loop = false;
            }
        },

        update: function (options) {
            this.setLoop(options);
            if ("volume" in options) {
                this.volume = options.volume;
            }
        },

        play: function (options) {
            if (options) {
                this.update(options);
            }

            if (!this.multiplay && this.playing) {
                return;
            }

            this.gain = audio.createGain();
            this.source = audio.createBufferSource();
            this.source.buffer = this.buffer;
            this.source.connect(this.gain);
            this.gain.connect(audio.destination);
            this.gain.gain.value = this.volume;

            this.source.onended = this.ended.bind(this);

            this._play();
        },

        _play: function () {
            var start,
                end;

            if (this.paused) {
                start = this.start + this.time_offset;
                end = this.end - this.time_offset;
            } else {
                start = this.start;
                end = this.end;
            }

            if (end <= 0) {
                this.clear();
                return;
            }

            if (typeof this.source.start === "function") {
                this.source.start(0, start, end);
            } else {
                this.source.noteOn(0, start, end);
            }

            this.playing = true;
            this.paused = false;
            this.time_started = new Date().valueOf();
        },

        stop: function () {
            if (this.playing && this.source) {
                if (typeof this.source.stop === "function") {
                    this.source.stop(0);
                } else {
                    this.source.noteOff(0);
                }
            }

            this.clear();
        },

        pause: function () {
            if (this.paused) {
                this.play();
                return;
            }

            if (!this.playing) {
                return;
            }

            this.source && this.source.stop(0);
            this.paused = true;
        },

        ended: function () {
            this.playing = false;
            this.time_ended = new Date().valueOf();
            this.time_played = (this.time_ended - this.time_started) / 1000;
            this.time_offset += this.time_played;

            if (this.time_offset >= this.end || this.end - this.time_offset < 0.015) {
                this._ended();
                this.clear();

                if (this.loop) {
                    this.loop--;
                    this.play();
                }
            }
        },

        _ended: function () {
            var config = {
                name: this.name,
                alias: this.alias,
                start: this.start,
                duration: this.end
            };

            if (this.ended_callback && typeof this.ended_callback === "function") {
                this.ended_callback.call(this.scope, config);
            }
        },

        clear: function () {
            this.time_played = 0;
            this.time_offset = 0;
            this.paused = false;
            this.playing = false;
        },

        setVolume: function (options) {
            this.volume = options.volume;

            if (this.gain) {
                this.gain.gain.value = this.volume;
            }
        }
    };

    if (audio) {
        return;
    }

    Sound.prototype = {
        init: function (options) {
            this.inited = true;
            if (options.preload) this.load();
        },

        destroy: function () {
            this.stream.destroy();
            this.stream = null;
            this.loaded = false;
            this.inited = false;
        },

        load: function () {
            var part;
            this.options.preload = true;
            this.options._ready = this.ready;
            this.options._scope = this;
            this.stream = new Stream(this.options);
        },

        ready: function (duration) {
            if (this.loaded) {
                return;
            }

            this.loaded = true;

            var config = {
                name: this.options.name,
                alias: this.options.alias,
                duration: duration
            };

            if (this.options.ready_callback && typeof this.options.ready_callback === "function") {
                this.options.ready_callback.call(this.options.scope, config);
            }

            if (this.autoplay) {
                this.autoplay = false;
                this.play();
            }
        },

        play: function (options) {
            if (!this.inited) {
                return;
            }
            if (!this.loaded) {
                if (!this.options.preload) {
                    this.autoplay = true;
                    this.load();
                } else {
                    this.autoplay = true;
                }

                return;
            }
            this.stream.play(this.options);
        },

        stop: function (options) {
            if (!this.inited) {
                return;
            }
            this.stream.stop();
        },

        pause: function (options) {
            if (!this.inited) {
                return;
            }
            this.stream.pause();
        },

        volume: function (options) {
            this.stream.setVolume(this.options);
        }
    };

    Stream = function (options) {
        this.name = options.name;
        this.alias = options.alias;

        this.multiplay = options.multiplay;
        this.volume = options.volume;
        this.preload = options.preload;
        this.start = options.start || 0;
        this.end = options.end || 0;
        this.scope = options.scope;
        this.ended_callback = options.ended_callback;

        this._scope = options._scope;
        this._ready = options._ready;

        this.setLoop(options);

        this.sound = null;
        this.url = null;
        this.loaded = false;

        this.start_time = 0;
        this.paused_time = 0;
        this.played_time = 0;

        this.init();
    };

    Stream.prototype = {
        init: function () {
            this.sound = new Audio();
            this.sound.volume = this.volume;

            this.sound.addEventListener("ended", this.ended.bind(this), false);
            this.sound.addEventListener("canplaythrough", this.can_play_through.bind(this), false);
            this.sound.addEventListener("timeupdate", this._update.bind(this), false);

            this.load();
        },

        destroy: function () {
            this.stop();

            this.sound.removeEventListener("ended", this.ended.bind(this), false);
            this.sound.removeEventListener("canplaythrough", this.can_play_through.bind(this), false);
            this.sound.removeEventListener("timeupdate", this._update.bind(this), false);

            this.sound = null;
            this.loaded = false;
        },

        can_play_through: function () {
            if (this.preload) {
                this.ready();
            }
        },

        load: function () {
            this.sound.src = this.url;
            this.sound.preload = this.preload ? "auto" : "none";
            if (this.preload) {
                this.sound.load();
            }
        },

        setLoop: function (options) {
            if (options.loop === true) {
                this.loop = 9999999;
            } else if (typeof options.loop === "number") {
                this.loop = +options.loop - 1;
            } else {
                this.loop = false;
            }
        },

        update: function (options) {
            this.setLoop(options);

            if ("volume" in options) {
                this.volume = options.volume;
            }
        },

        ready: function () {
            if (this.loaded || !this.sound) {
                return;
            }

            this.loaded = true;
            this._ready.call(this._scope, this.sound.duration);

            if (!this.end) {
                this.end = this.sound.duration;
            }
        },

        play: function (options) {
            if (options) {
                this.update(options);
            }

            if (!this.multiplay && this.playing) {
                return;
            }

            this._play();
        },

        _play: function () {
            if (this.paused) {
                this.paused = false;
            } else {
                try {
                    this.sound.currentTime = this.start;
                } catch (e) {}
            }

            this.playing = true;
            this.start_time = new Date().valueOf();
            this.sound.volume = this.volume;
            this.sound.play();
        },

        stop: function () {
            if (!this.playing) {
                return;
            }

            this.playing = false;
            this.paused = false;
            this.sound.pause();
            this.clear();

            try {
                this.sound.currentTime = this.start;
            } catch (e) {}
        },

        pause: function () {
            if (this.paused) {
                this._play();
            } else {
                this.playing = false;
                this.paused = true;
                this.sound.pause();
                this.paused_time = new Date().valueOf();
                this.played_time += this.paused_time - this.start_time;
            }
        },

        _update: function () {
            if (!this.start_time) {
                return;
            }

            var current_time = new Date().valueOf(),
                played_time = current_time - this.start_time,
                played = (this.played_time + played_time) / 1000;

            if (played >= this.end) {
                if (this.playing) {
                    this.stop();
                    this._ended();
                }
            }
        },

        ended: function () {
            if (this.playing) {
                this.stop();
                this._ended();
            }
        },

        _ended: function () {
            this.playing = false;

            var config = {
                name: this.name,
                alias: this.alias,
                start: this.start,
                duration: this.end
            };

            if (this.ended_callback && typeof this.ended_callback === "function") {
                this.ended_callback.call(this.scope, config);
            }

            if (this.loop) {
                setTimeout(this.looper.bind(this), 15);
            }
        },

        looper: function () {
            this.loop--;
            this.play();
        },

        clear: function () {
            this.start_time = 0;
            this.played_time = 0;
            this.paused_time = 0;
        },

        setVolume: function (options) {
            this.volume = options.volume;

            if (this.sound) {
                this.sound.volume = this.volume;
            }
        }
    };

} (window, navigator, window.jQuery || window.$));