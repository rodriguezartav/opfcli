oauth   = require 'oauth'
sys     = require 'sys'
winston = require 'winston'

class TwitterController

  constructor: (@app) ->
    @consumerKey= process.env.TWITTER_consumerKey
    @consumerSecret= process.env.TWITTER_consumerSecret
    @baseURL= process.env.TWITTER_baseURL

    @consumer = new oauth.OAuth(
      "https://twitter.com/oauth/request_token", "https://twitter.com/oauth/access_token",
      @consumerKey, @consumerSecret
      "1.0A", "#{@baseURL}/sessions/twitter/callback", "HMAC-SHA1")

    @app.use @middleware()

  middleware: =>
    return (req , res , next)  =>
      console.log "twitter pass"
      req.twitterController = @
      return @startAuth(req,res) if(req.url?.indexOf("/sessions/twitter/login")     == 0)
      return @finishAuth(req,res) if(req.url?.indexOf("/sessions/twitter/callback")  == 0)
      next()

  startAuth: (req, res) =>
    req.session.lastView = req.query.lastView

    @consumer.getOAuthRequestToken (error, oauthToken, oauthTokenSecret, results) ->
      if error
        return TwitterController.sendError req, res, "Error getting OAuth request token : " + sys.inspect(error), 500
      else
        req.session.oauthRequestToken = oauthToken
        req.session.oauthRequestTokenSecret = oauthTokenSecret
        return res.redirect "https://twitter.com/oauth/authorize?oauth_token=#{req.session.oauthRequestToken}"

  finishAuth: (req,res) =>

    @consumer.getOAuthAccessToken req.session.oauthRequestToken, req.session.oauthRequestTokenSecret , req.query.oauth_verifier ,
      (err, oauthAccessToken, oauthAccessTokenSecret, results) =>

        if err
          TwitterController.sendError req, res, "Error getting OAuth access token : #{sys.inspect(err)}" +
            "[#{oauthAccessToken}] [#{oauthAccessTokenSecret}] [#{sys.inspect(results)}]" 

        if results
          req.session.authData = TwitterController.toParseAuthData(results , oauthAccessToken , oauthAccessTokenSecret)   
          TwitterController.prepareReq(req)
          
          #get extra details
          @getJSON "/users/show.json?screen_name=#{req.user.twitter.screen_name}", req, (err, data, response) ->
            req.session.authData.twitter.details = data
            res.redirect "/"
  
  @prepareReq: (req) ->
    req.session.oauthRequestToken = null
    req.session.oauthRequestTokenSecret = null
    req.user = {}
    req.user.twitter = req.session.authData.twitter

  @toParseAuthData: (results,oauthAccessToken,oauthAccessTokenSecret) ->
    twitter:
      id: results.user_id
      screen_name: results.screen_name
      auth_token: oauthAccessToken
      auth_token_secret: oauthAccessTokenSecret
      consumer_key: process.env.TWITTER_consumerKey
      consumer_secret: process.env.TWITTER_consumerSecret
    
  @sendError: (req,res,err) ->
    if err
      if process.env['NODE_ENV']=='development'
        res.send "Login error: #{err}", 500
      else
        res.send '<h1>Sorry, a login error occurred</h1>', 500
    else
      res.redirect '/' # todo

  ##############################################################################
  # SERVICES CALLS CALLS
  ##############################################################################


  get: (url, req, callback) ->
    callback 'no twitter session' unless req.user.twitter?
    @consumer.get url, req.user.twitter.accessToken, req.user.twitter.accessTokenSecret,
    (err, data, response) ->
      callback err, data, response

  getJSON: (apiPath, req, callback) ->
    callback 'no twitter session' unless req.user.twitter?
    @consumer.get "http://api.twitter.com/1#{apiPath}", req.user.twitter.accessToken, req.user.twitter.accessTokenSecret,
    (err, data, response) ->
      console.log data
      console.log "dataend"
      callback err, JSON.parse(data), response

  post: (url, body, req, callback) ->
    callback 'no twitter session' unless req.user.twitter?
    @consumer.post url, req.user.twitter.accessToken, req.user.twitter.accessTokenSecret, body,
    (err, data, response) ->
      callback err, data, response

  postJSON: (apiPath, body, req, callback) ->
    callback 'no twitter session' unless req.user.twitter?
    url = "http://api.twitter.com/1#{apiPath}"
    @consumer.post url, req.user.twitter.accessToken, req.user.twitter.accessTokenSecret, body,
    (err, data, response) ->
      callback err, JSON.parse(data), response

  ##############################################################################
  # SPECIFIC CALLS
  ##############################################################################

  getSelf: (req, callback) ->
    @get 'http://twitter.com/account/verify_credentials.json', req, (err, data, response) ->
      callback err, JSON.parse(data), response

  getFollowerIDs: (name, req, callback) ->
    @getJSON "/followers/ids.json?screen_name=#{name}&stringify_ids=true", req, (err, data, response) ->
      callback err, data, response

  getFriendIDs: (name, req, callback) ->
    @getJSON "/friends/ids.json?screen_name=#{name}&stringify_ids=true", req, (err, data, response) ->
      callback err, data, response

  getUsers: (ids, req, callback) ->
    @getJSON "/users/lookup.json?include_entities=false&user_id=#{ids.join(',')}", req, (err, data, response) ->
      callback err, data, response

  follow: (id, req, callback) ->
    @postJSON "/friendships/create/#{id}.json", "", req, (err, data, response) ->
      callback err, data, response

  unfollow: (id, req, callback) ->
    @postJSON "/friendships/destroy/#{id}.json", "", req, (err, data, response) ->
      callback err, data, response

  status: (status, req, callback) ->
    @postJSON "/statuses/update.json?status=#{status}", '', req, (err, data, response) ->
      callback err

module.exports = TwitterController