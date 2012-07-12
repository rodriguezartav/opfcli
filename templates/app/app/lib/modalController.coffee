Spine   = require('spine')
$       = Spine.$

Spine.Controller.ModalController =

  extended: ->
    @include
        
      setupModal: =>
        Spine.bind "show_modal" , ( type , data =null , callback=null ) =>
          throw "You need to use lib/modal or setup up Spine.modals =[modal1,modal2,modal3] before calling setupModal" if !Spine.modals
          Spine.lightboxDiv.show()
          @current = null
          for item in Spine.modals
            @current = item if item.type == type
          if @current
            @current = new @current(data: data, callback: callback)
            Spine.lightboxDiv.html @current.el
            
        Spine.bind "hide_modal" , =>
          @current?.release?()
          @current = null
          Spine.lightboxDiv.empty()
          Spine.lightboxDiv.hide()

        Spine.lightboxDiv = $('<div class="lightbox  reveal-modal-bg"></div>')
        $("body").append Spine.lightboxDiv

      
module?.exports = Spine.Controller.ModalController

