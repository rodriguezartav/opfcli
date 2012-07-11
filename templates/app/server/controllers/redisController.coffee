Redis = require("redis")
url = require("url")
express = require('express')
RedisStore = require('connect-redis')(express);

class RedisController

  @client = null

  constructor: (@app) ->
    client = RedisController.getClient()
    if client
      @app.use express.session { store: new RedisStore(client: RedisController.getClient() )  , secret: 'noMatterHowSafe_w3are' }
    else
      @app.use express.session secret: "1.6km is a mile"
      
  
  
  @getClient: =>
    return false if !process.env.REDISTOGO_URL
    return @client = @client

    rtg   = require("url").parse(process.env.REDISTOGO_URL);
    @client = Redis.createClient(rtg.port, rtg.hostname);
    @client.auth(rtg.auth.split(":")[1]);
    @client.on "error", (msg) ->
      console.log msg

    return @client



module.exports =  RedisController