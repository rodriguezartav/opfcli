
class Routes

  constructor: (@app) ->    
    @app.use @middleware()
    @setupRoutes()

  middleware: =>
    return (req,res,next)  =>
      req.message = "This is an example of a middleware in /server/routes#middleware"
      next()

  setupRoutes: ->
   #ROUTES GO HERE
    @app.get "/", (req,res) ->
      res.render "index" , { message: req.message }

module.exports = Routes
