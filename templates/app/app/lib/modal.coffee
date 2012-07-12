Spine   = require('spine')
$       = Spine.$

Spine.Controller.Modal =

  extended: ->
    Spine.modals = [] if !Spine.modals
    Spine.modals.push @

module?.exports = Spine.Controller.Modal

