Events =
  bind: (ev, callback) ->
    evs   = ev.split(' ')
    calls = @hasOwnProperty('_callbacks') and @_callbacks or= {}

    for name in evs
      calls[name] or= []
      calls[name].push(callback)
    this

  one: (ev, callback) ->
    @bind ev, ->
      @unbind(ev, arguments.callee)
      callback.apply(@, arguments)

  trigger: (args...) ->
    ev = args.shift()

    list = @hasOwnProperty('_callbacks') and @_callbacks?[ev]
    return unless list

    for callback in list
      if callback.apply(@, args) is false
        break
    true

  unbind: (ev, callback) ->
    unless ev
      @_callbacks = {}
      return this

    list = @_callbacks?[ev]
    return this unless list

    unless callback
      delete @_callbacks[ev]
      return this

    for cb, i in list when cb is callback
      list = list.slice()
      list.splice(i, 1)
      @_callbacks[ev] = list
      break
    this

Log =
  trace: true

  logPrefix: '(App)'

  log: (args...) ->
    return unless Opf.debug
    if @logPrefix then args.unshift(@logPrefix)
    console?.log?(args...)
    this

moduleKeywords = ['included', 'extended']

class Module
  @include: (obj) ->
    throw('include(obj) requires obj') unless obj
    for key, value of obj when key not in moduleKeywords
      @::[key] = value
    obj.included?.apply(@)
    this

  @extend: (obj) ->
    throw('extend(obj) requires obj') unless obj
    for key, value of obj when key not in moduleKeywords
      @[key] = value
    obj.extended?.apply(@)
    this

  @proxy: (func) ->
    => func.apply(@, arguments)

  proxy: (func) ->
    => func.apply(@, arguments)

  constructor: ->
    @init?(arguments...)
    
# Globals

Opf = @Opf   = {}
module.exports  = Opf

Opf.version    = '0.0.5'
Opf.debug      = false
Opf.Events     = Events
Opf.Log        = Log
Opf.log        = Log.log
Opf.Module     = Module

# Global events

Module.extend.call(Opf, Events)