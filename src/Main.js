"use strict";

// module Main

var cheerio = require('cheerio');
var irc = require('irc');
var Pinboard = require('node-pinboard');
var request = require('request');
var twitter = require('twitter-text');

exports.newClient = function (server) {
    return function (nick) {
        return function (opts) {
            return function () {
                return new irc.Client(server, nick, opts);
            };
        };
    };
};

exports.addListener = function (client) {
    return function (on) {
        return function (callback) {
            return function () {
                client.addListener(on, function () {
                    callback.apply(null, arguments)();
                });
                return {};
            };
        };
    };
};

var pinboard = new Pinboard('utdlug:');

exports.process = function (client) {
    return function(from) {
        return function (to) {
            return function (message) {
                return function () {
                    twitter.extractUrls(message).forEach(function (url) {
                        try {
                            if (url.substring(0, 4) != 'http') {
                                url = 'http://' + url;
                            }
                            request(url, function (err, res, body) {
                                var title = cheerio.load(body || '')('title').text();
                                pinboard.add({
                                    url: url,
                                    description: title || url,
                                    tags: ['by:' + from].concat(twitter.extractHashtags(message)).join(','),
                                    replace: 'no',
                                }, function (res) {
                                    if (title) {
                                        client.say('#utdlug', title);
                                    }
                                    console.log(res);
                                })
                            });
                        } catch (e) {
                            console.log(e);
                        }
                    });
                };
            };
        };
    };
};
