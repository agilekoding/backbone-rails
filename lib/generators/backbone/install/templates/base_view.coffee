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

    if @model?
      link = $(e.currentTarget)
      return false unless @allowAction(link)

      @model.destroy(options)
      @remove()

  save: (e, options = {}) ->
    e.preventDefault()
    e.stopPropagation()

    form   = $(e.currentTarget)
    _model = options.model || @model

    options = _.extend(
      success: (model) =>
        window.location.hash = "/#{_model.id}"
      error: (model, jqXHR) =>
        @renderErrors( model, $.parseJSON( jqXHR.responseText ).errors )

      options)

    if _model.isValid() is true
      return false unless @allowAction(form)

      settings =
        success: (model, jqXHR) =>
          window.router._editedModels = []
          _model.resetRelations(jqXHR)
          _model.allValuesSeted = true
          model.trigger("afterSave", model, jqXHR)
          options.success(model, jqXHR)
        error: options.error

      if !(_model.collection?) and @collection?
        @collection.create _model, settings
      else _model.save null, settings

    else @renderErrors(_model, _model.errors, form)

  update: (e, options = {}) ->
    e.preventDefault()
    e.stopPropagation()

    form   = $(e.currentTarget)
    _model = options.model || @model

    options = _.extend(
      success : (model) =>
        window.location.hash = "/#{_model.id}"
      error: (model, jqXHR) =>
        @renderErrors( model, $.parseJSON( jqXHR.responseText ).errors, form )

      options)

    if _model.isValid() is true
      return false unless @allowAction(form)
      _model.save(null,
        success: (model, jqXHR) =>
          window.router._editedModels = []
          _model.resetRelations(jqXHR)
          _model.allValuesSeted = true
          model.trigger("afterSave", model, jqXHR)
          options.success(model, jqXHR)
        error: options.error
      )
    else @renderErrors(_model, _model.errors)

  # Progress bar
  # ==========================================================
  renderProgress: (schedule_id, callback) ->
    <%= js_app_name %>.Helpers.renderProgress(schedule_id, callback)

  # Errors
  # ==========================================================
  renderErrors: (model, errors, alertsContainer = false) ->
    alertsContainer = false if _.isEmpty alertsContainer
    fullErrors      = {}

    if errors?
      _.each(errors, (messages, key) =>
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
      )
    else
      alertsContainer ||= "#alerts_container"
      (fullErrors.messages ||= []).push({name: "", message: @t("errors.default")})

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

        disabled_object = $("a[href=\"#\"], input[type=\"submit\"].btn")

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
