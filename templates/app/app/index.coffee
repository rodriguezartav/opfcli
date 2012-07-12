require('lib/setup')

Spine = require('spine')

GeneralModal   = require("modals/generalModal")

class App extends Spine.Controller
  @extend Spine.Controller.ModalController

  constructor: ->
    super    
    @setupModal()

    Spine.trigger "show_modal" , "general"

module.exports = App
    