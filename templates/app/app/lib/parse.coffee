Spine  = @Spine or require('spine')
$      = Spine.$
Model  = Spine.Model

$.ajaxSetup
  headers: 
    "X-Parse-Application-Id" : "",
    "X-Parse-REST-API-Key": ""

Ajax =
  getURL: (object) ->
    object and object.url?() or object.url

  enabled:  true
  pending:  false
  requests: []

  disable: (callback) ->
    if @enabled
      @enabled = false
      try
        do callback
      catch e
        throw e
      finally
        @enabled = true
    else
      do callback

  requestNext: ->
    next = @requests.shift()
    if next
      @request(next)
    else
      @pending = false

  request: (callback) ->
    (do callback).complete(=> do @requestNext)

  queue: (callback) ->
    return unless @enabled
    if @pending
      @requests.push(callback)
    else
      @pending = true
      @request(callback)
    callback

class Base
  defaults:
    contentType: 'application/json'
    dataType: 'json'
    processData: false

  ajax: (params, defaults) ->
    $.ajax($.extend({}, @defaults, defaults, params))

  queue: (callback) ->
    Ajax.queue(callback)

class Collection extends Base
  constructor: (@model) ->

  custom: ( method , params , options) ->
    url = params.url || Ajax.getURL(@model)
    params.data = JSON.stringify(params.data) if params.data and typeof params.data  is "object"
    @ajax(
      params,
      type: method,
      url: url
    ).success( @customResponse(options) )
    .error( @customErrorResponse(options) )

  find: (id, params) ->
    record = new @model(id: id)
    @ajax(
      params,
      type: 'GET',
      url:  Ajax.getURL(record)
    ).success(@recordsResponse)
     .error(@errorResponse)

  all: (params) ->
    @ajax(
      params,
      type: 'GET',
      url:  Ajax.getURL(@model)
    ).success(@recordsResponse)
     .error(@errorResponse)

  fetch: (params = {}, options = {}) ->
    if id = params.id
      delete params.id
      @find(id, params).success (record) =>
        @model.refresh(record, options)
    else
      @all(params).success (records) =>
        @model.refresh(records, options)

  # Private

  customResponse: (options = {}) =>
    (data, status, xhr) =>
      @model = Spine if !@model # to allow external access
      @model.trigger('customAjaxSuccess', data, status, xhr)
      options.success?.apply( @model, [data])

  recordsResponse: (data, status, xhr) =>
    @model.trigger('ajaxSuccess', null, status, xhr)

  errorResponse: (xhr, statusText, error) =>
    @model.trigger('ajaxError', null, xhr, statusText, error)

  customErrorResponse: (options = {}) =>
    (xhr, statusText, error) =>
      @model = Spine if !@model # to allow external access
      @model.trigger('ajaxError', xhr, statusText, error)
      options.error?.apply(@model , [xhr, statusText, error] )

class Singleton extends Base
  constructor: (@record) ->
    @model = @record.constructor

  reload: (params, options) ->
    @queue =>
      @ajax(
        params,
        type: 'GET'
        url:  Ajax.getURL(@record)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

  create: (params, options) ->
    @queue =>
      @ajax(
        params,
        type: 'POST'
        data: JSON.stringify(@record)
        url:  Ajax.getURL(@model)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

  update: (params, options) ->
    data = @record.forSave?()
    
    @queue =>
      @ajax(
        params,
        type: 'PUT'
        data: JSON.stringify( data || @record)
        url:  Ajax.getURL(@record)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

  destroy: (params, options) ->
    @queue =>
      @ajax(
        params,
        type: 'DELETE'
        url:  Ajax.getURL(@record)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

  # Private

  recordResponse: (options = {}) =>
    (data, status, xhr) =>
      if Spine.isBlank(data)
        data = false
      else
        data = @model.fromJSON(data)

      Ajax.disable =>
        if data
          # ID change, need to do some shifting
          if data.id and @record.id isnt data.id
            @record.changeID(data.id)

          # Update with latest data
          @record.updateAttributes(data.attributes())

      @record.trigger('ajaxSuccess', data, status, xhr)
      options.success?.apply(@record)

  errorResponse: (options = {}) =>
    (xhr, statusText, error) =>
      @record.trigger('ajaxError', xhr, statusText, error)
      options.error?.apply(@record, [xhr, statusText, error] )

# Ajax endpoint
Model.host = 'https://api.parse.com/1'

Include =
  ajax: -> new Singleton(this)

  url: (args...) ->
    url = Ajax.getURL(@constructor)
    url += '/' unless url.charAt(url.length - 1) is '/'
    url += encodeURIComponent(@id)
    args.unshift(url)
    args.join('/')

Extend =
  ajax: -> new Collection(this)

  url: (args...) ->
    args.unshift(@className.toLowerCase() + 's')
    args.unshift(Model.host)
    args.join('/')

Model.Ajax =
  extended: ->
    @fetch @ajaxFetch
    @change @ajaxChange

    @extend Extend
    @include Include

  # Private

  ajaxFetch: ->
    @ajax().fetch(arguments...)

  ajaxChange: (record, type, options = {}) ->
    return if options.ajax is false
    record.ajax()[type](options.ajax, options)

Model.Ajax.Methods =
  extended: ->
    @extend Extend
    @include Include

# Globals
Ajax.defaults   = Base::defaults
Spine.Ajax      = Ajax
Spine.AjaxUtil = new Collection()
module?.exports = Ajax