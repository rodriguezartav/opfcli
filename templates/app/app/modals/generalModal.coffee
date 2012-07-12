Spine   = require('spine')
$       = Spine.$

class GeneralModal extends Spine.Controller
  @extend Spine.Controller.Modal
  
  className: 'showGeneral modal'

  @type = "general"

  events:
    "click .cancel" : "onClose"

  constructor: ->
    super
    @render()

  render: =>
    @html require("views/modals/generalModal")(@data)

  onClose: =>
    Spine.trigger "hide_modal"

module.exports = GeneralModal
