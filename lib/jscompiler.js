// Generated by CoffeeScript 1.3.1
(function() {
  var compilers, fs, jscompiler, optimist, path, pck;

  fs = require('fs');

  path = require('path');

  optimist = require('optimist');

  compilers = require('./compilers');

  pck = require('./package');

  jscompiler = (function() {

    jscompiler.name = 'jscompiler';

    function jscompiler() {}

    jscompiler.compile = function() {
      return pck.createPackage({
        dependencies: ["es5-shimify", "json2ify", "jqueryify", "spine", "spine/lib/local", "spine/lib/ajax", "spine/lib/route"],
        paths: ['./app'],
        libs: []
      });
    };

    return jscompiler;

  })();

  module.exports = jscompiler;

}).call(this);