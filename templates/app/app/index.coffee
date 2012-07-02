require('lib/setup')

Spine = require('spine')

class App extends Spine.Controller

  constructor: ->
    super
    @html require("views/layout")

module.exports = App
    