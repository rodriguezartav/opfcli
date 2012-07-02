fs = require('fs')
path       = require('path')
optimist   = require('optimist')
compilers  = require('./compilers')
pck        = require('./package')

class jscompiler

  @compile: ->
    pck.createPackage(
      dependencies: [
        "es5-shimify", 
        "json2ify", 
        "jqueryify", 
        "spine",
        "spine/lib/local",
        "spine/lib/ajax",
        "spine/lib/route"],
      paths: ['./app'],
      libs: []
    )
  
module.exports = jscompiler