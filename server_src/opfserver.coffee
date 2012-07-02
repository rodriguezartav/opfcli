css        = require('./css')
jscompiler = require('./jscompiler')


class Opfserver

  @setupRoutes: (app) ->
    Less = require('less')  

    app.get '/application.js' , jscompiler.compile().createServer()
    
    app.get '/application.css' , (req,res) =>
      content = css.compile (content , success ) ->
        if success
          res.header("Content-type", "text/css");
          res.send(content)
        else
          res.send(500)

module.exports = Opfserver
