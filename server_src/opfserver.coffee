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

  @middleware: ->
    return (req,res,next)  =>
      return next() if process.env.NODE_ENV == 'production'
      
      if req.url == '/application.js' 
        content = jscompiler.compile().compile()
        res.writeHead 200, 'Content-Type': 'text/javascript'
        res.end content

      else if req.url == '/application.css'
        content = css.compile (content , success ) ->
          if success
            res.header("Content-type", "text/css");
            res.send(content)
          else
            res.send(500)
      else
        next()


module.exports = Opfserver


