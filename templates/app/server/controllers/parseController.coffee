Kaiseki = require("kaiseki")

class ParseController

  constructor: (@app) ->
    @kaiseki = new Kaiseki(process.env.PARSE_APP_ID, process.env.PARSE_REST_API_KEY);
    
    @app.use @middleware()

  middleware: =>
    return (req , res , next)  =>
      console.log "parse pass"
      req.parseController = @
      next()

module.exports = ParseController