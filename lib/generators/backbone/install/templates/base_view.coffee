class <%= js_app_name %>.Views.BaseView extends Backbone.View

  _.extend @, Modules.Inheritance

  @include Modules.Validations
  @include Modules.NumberHelper
  @include Modules.Pagination
  @include Modules.AjaxRequests
  @include Modules.I18n

  constructor: ->
    @beforeInitialize()
    super(arguments...)
    @afterInitialize()

  # Callbacks
  # ==========================================================
  beforeInitialize: ->
    _.each(@_beforeInitialize, (callback, key) =>
      callback?.apply(@)
    )

  afterInitialize: ->
    _.each(@_afterInitialize, (callback, key) =>
      callback?.apply(@)
    )

  beforeRemove: ->
    _.each(@_beforeRemove, (callback, key) =>
      callback?.apply(@)
    )

  # Defaults Events
  # ==========================================================
  events:
    "click .destroy" : "destroy"
    "click div.pagination a" : "pagination"

  allowAction: (element) ->
    message = element.attr("data-confirm") || element.attr("confirm")
    !message || confirm(message)

  destroy: (e, options = {}) ->
    e.preventDefault()
    return false unless model = options.model || @model

    link = $(e.currentTarget)

    unless model.isNew()
      return false unless @allowAction(link)

      options = _.extend
        success: => @remove?()
        error: (model, jqXHR) =>
          data = $.parseJSON(jqXHR.responseText)
          @renderErrors( model, (data.error || data.errors) )

        options

      model.destroy(options)

    else
      model.destroy()
      @remove?()

  save: (e, options = {}) ->
    e.preventDefault()
    e.stopPropagation()

    form   = $(e.currentTarget)
    _model = options.model || @model

    if _model.isValid() is true
      return false unless @allowAction(form)

      files = $(":file", form)
      if form.prop("enctype") is "multipart/form-data" and files.length > 0
        save_with_files.call(this, form, _model, files, "new", options)
      else save_without_files.call(this, form, _model, "new", options)

    else @renderErrors(_model, _model.errors, form)

  update: (e, options = {}) ->
    e.preventDefault()
    e.stopPropagation()

    form   = $(e.currentTarget)
    _model = options.model || @model

    if _model.isValid() is true
      return false unless @allowAction(form)

      files = $(":file", form)
      if form.prop("enctype") is "multipart/form-data" and files.length > 0
        save_with_files.call(this, form, _model, files, "edit", options)
      else save_without_files.call(this, form, _model, "edit", options)

    else @renderErrors(_model, _model.errors)

  # Progress bar
  # ==========================================================
  renderProgress: (schedule_id, callback) ->
    <%= js_app_name %>.Helpers.renderProgress(schedule_id, callback)

  # Errors
  # ==========================================================
  renderErrors: (model, errors, alertsContainer = false) ->
    alertsContainer = false if _.isEmpty(alertsContainer)
    errors          = { base: errors } if _.isString(errors)
    fullErrors      = {}

    unless _.isEmpty(errors)
      _.each errors, (messages, key) =>
        if model?
          name = model.humanAttributeName(key)
        else
          alertsContainer ||= "#alerts_container"
          name            = @t("activerecord.attributes.#{key}")

        if _.isString messages
          (fullErrors.messages ||= []).push({name: "", message: messages})
        else
          for message in messages
            name = "" if name is "base"
            (fullErrors.messages ||= []).push({name: name, message: message})

    unless errors?
      alertsContainer ||= "#alerts_container"
      (fullErrors.messages ||= []).push({name: "", message: @t("errors.default")})

    unless _.isEmpty(fullErrors)
      <%= js_app_name %>.Helpers.renderError(fullErrors, alertsContainer)

  # Remove Callbacks in beforeRemove() function if needed
  # ==========================================================
  remove: ->
    @beforeRemove()
    super()

  delegateEvents: (events) ->
    # Cached regex to split keys for `delegate`.
    eventSplitter = /^(\S+)\s*(.*)$/

    return if (!(events || (events = @events)))
    events = events.call(this) if (_.isFunction(events))

    waitingProxy = (func, thisObject) ->
      (e) ->
        trigger_object  = $(e.currentTarget)
        waiting         = trigger_object.is(".disabled")

        disabled_object = $("a[href=\"#\"]:not(.disabled), input[type=\"submit\"].btn:not(.disabled)")

        if waiting then e.preventDefault()
        else
          trigger_object.addClass("disabled")
          disabled_object.addClass("disabled")

          enableFunc = ->
            trigger_object.removeClass("disabled")
            disabled_object.removeClass("disabled")

          $.when(func.apply(thisObject, arguments)).then(enableFunc, enableFunc)

    $(@el).unbind(".delegateEvents#{@cid}")

    for key of events
      method = this[events[key]]
      throw new Error("Event #{events[key]} does not exist") unless method

      match     = key.match(eventSplitter)
      eventName = match[1]
      selector  = match[2]
      method    = waitingProxy(method, this)
      eventName += ".delegateEvents#{@cid}"

      if selector is '' then $(@el).bind(eventName, method)
      else $(@el).delegate(selector, eventName, method)

# Private Methods
# ==========================================================

# Update Functions
# ==========================================================
save_with_files = (form, _model, files, form_type, options) ->
  data        = form.serializeArray() || {}
  success     = success_function(_model, options)
  error       = error_function(_model, options)
  options.url = getUrl(_model) unless options.url?
  type        = methodMap[form_type]

  options = _.extend(
    files       : files
    iframe      : true
    processData : false
    type        : type
    data        : data

    complete: (jqXHR, textStatus) =>
      data = $.parseJSON( jqXHR.responseText )

      if data.ok is true
        save_model.call(this, _model, form_type, data.resource)
        add_to_collection.call(this, _model) if form_type is "new"
        success.call(this, _model, data.resource)
        show_success_message.call this, _model, form_type
      else error.call(this, _model, data.errors, form)

    options)

  @doAjax options


save_without_files = (form, _model, form_type, options) ->
  success = success_function(_model, options)
  error   = error_function(_model, options)

  options = _.extend(
    success: (model, jqXHR) =>
      save_model.call(this, _model, form_type, jqXHR)
      success.call(this, _model, jqXHR)
      show_success_message.call this, _model, form_type
    error: (model, jqXHR) =>
      errors = $.parseJSON(jqXHR.responseText).errors
      error.call(this, model, errors, form)

    options)

  if form_type is "new"
    @collection.create(_model, options)
  else _model.save(null, options)

# ==========================================================

success_function = (model, options) ->
  success         = options.success
  options.success = null
  delete options.success
  return success if _.isFunction(success)
  (model) -> window.location.hash = "/#{model.id}"

error_function = (model, options) ->
  error         = options.error
  options.error = null
  delete options.error
  return error if _.isFunction(error)
  (model, errors, form) -> @renderErrors(model, errors, form)

save_model = (model, type, resource) ->
  window.router._editedModels = []
  model.resetRelations(resource)
  model.allValuesSeted = true
  model.trigger("afterSave", model, resource)

add_to_collection = (_model) -> @collection.add(_model)

show_success_message = (_model, type) ->
  attrs = model_name: _model.humanName()
  @flash "success", @t("helpers.#{type}.success", attrs)

getUrl = (model) ->
  if _.isFunction(model.url) then model.url() else model.url

methodMap = { "new" : "POST", "edit" : "PUT" }
