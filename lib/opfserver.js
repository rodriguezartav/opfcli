var Opfserver, css, jscompiler;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
css = require('./css');
jscompiler = require('./jscompiler');
Opfserver = (function() {
  function Opfserver() {}
  Opfserver.setupRoutes = function(app) {
    var Less;
    Less = require('less');
    app.get('/application.js', jscompiler.compile().createServer());
    return app.get('/application.css', __bind(function(req, res) {
      var content;
      return content = css.compile(function(content, success) {
        if (success) {
          res.header("Content-type", "text/css");
          return res.send(content);
        } else {
          return res.send(500);
        }
      });
    }, this));
  };
  Opfserver.middleware = function() {
    return __bind(function(req, res, next) {
      var content;
      if (process.env.NODE_ENV === 'production') {
        next();
      }
      if (req.url === '/application.js') {
        content = jscompiler.compile().compile();
        res.writeHead(200, {
          'Content-Type': 'text/javascript'
        });
        return res.end(content);
      } else if (req.url === '/application.css') {
        return content = css.compile(function(content, success) {
          if (success) {
            res.header("Content-type", "text/css");
            return res.send(content);
          } else {
            return res.send(500);
          }
        });
      } else {
        return next();
      }
    }, this);
  };
  return Opfserver;
})();
module.exports = Opfserver;