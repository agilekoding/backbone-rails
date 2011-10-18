class <%= js_app_name %>.Views.BaseView extends Backbone.View

  # Defaults Events
  events:
    "click .destroy" : "destroy"

  destroy: (e, options = {}) ->
    msg = $(e.currentTarget).attr("data-confirm")
    if msg? and !confirm(msg) then return false

    @model.destroy(options)
    @remove()

    return false

  save: (e, options = {}) ->
    e.preventDefault()
    e.stopPropagation()

    msg = $(e.currentTarget).attr("confirm")
    if msg? and !confirm(msg) then return false

    options = _.extend(
      success: (model) =>
        @model = model
        window.location.hash = "/#{@model.id}"
      error: (model, jqXHR) =>
        @renderErrors( model, $.parseJSON( jqXHR.responseText ) )

      options)

    if @model.isValid()
      @collection.create(@model,
        success: (model, jqXHR) ->
          window.router._editedModels = []
          model.trigger("afterSave", model, jqXHR)
          options.success(model, jqXHR)
        error: options.error
      )
    else @renderErrors(@model, @model.errors)

  update : (e, options = {}) ->
    e.preventDefault()
    e.stopPropagation()

    msg = $(e.currentTarget).attr("confirm")
    if msg? and !confirm(msg) then return false

    options = _.extend(
      success : (model) =>
        @model = model
        window.location.hash = "/#{@model.id}"
      error: (model, jqXHR) =>
        @renderErrors( model, $.parseJSON( jqXHR.responseText ) )

    options)

    if @model.isValid()
      @model.save(null,
        success: (model, jqXHR) ->
          window.router._editedModels = []
          model.trigger("afterSave", model, jqXHR)
          options.success(model, jqXHR)
        error: options.error
      )
    else @renderErrors(@model, @model.errors)

  renderErrors: (model, errors) ->
    fullErrors = {}
    _.each(errors, (messages, key) ->
      name = $('label[for="' + model.paramRoot + '_' + key + '"]').text() || key
      for message in messages
        (fullErrors.errors ||= []).push({name: name, message: message})
    )
    <%= js_app_name %>.Helpers.renderErrors(fullErrors)
