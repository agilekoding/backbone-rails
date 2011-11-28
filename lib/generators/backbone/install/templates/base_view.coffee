class <%= js_app_name %>.Views.BaseView extends Backbone.View

  _.extend @, Modules.Inheritance

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

    form = $(e.currentTarget)
    return false unless @allowAction(form)

    options = _.extend(
      success: (model) =>
        window.location.hash = "/#{@model.id}"
      error: (model, jqXHR) =>
        @renderErrors( model, $.parseJSON( jqXHR.responseText ) )

      options)

    if @model.isValid() is true
      @collection.create(@model,
        success: (model, jqXHR) =>
          window.router._editedModels = []
          @model.resetRelations(jqXHR)
          model.trigger("afterSave", model, jqXHR)
          options.success(model, jqXHR)
        error: options.error
      )
    else @renderErrors(@model, @model.errors)

  update: (e, options = {}) ->
    e.preventDefault()
    e.stopPropagation()

    form = $(e.currentTarget)
    return false unless @allowAction(form)

    options = _.extend(
      success : (model) =>
        window.location.hash = "/#{@model.id}"
      error: (model, jqXHR) =>
        @renderErrors( model, $.parseJSON( jqXHR.responseText ) )

    options)

    if @model.isValid() is true
      @model.save(null,
        success: (model, jqXHR) =>
          window.router._editedModels = []
          @model.resetRelations(jqXHR)
          model.trigger("afterSave", model, jqXHR)
          options.success(model, jqXHR)
        error: options.error
      )
    else @renderErrors(@model, @model.errors)

  # Errors
  # ==========================================================
  renderErrors: (model, errors) ->
    fullErrors = {}
    _.each(errors, (messages, key) ->
      name = model.humanAttributeName(key)
      for message in messages
        (fullErrors.messages ||= []).push({name: name, message: message})
    )
    <%= js_app_name %>.Helpers.renderError(fullErrors)

  # Pagination
  # ==========================================================
  pagination: (e, collection) ->
    e.preventDefault()
    link      = $(e.currentTarget)
    li        = link.closest("li")
    container = link.closest("#pagination-container")

    unless li.is(".active, .prev.disabled, .next.disabled")
      unless container.attr("data-waiting")
        container.attr("data-waiting", true)
        href = link.attr("href")
        <%= js_app_name %>.Helpers.jsonCallback(href, (data) ->
          collection.pagination = data.pagination
          collection.reset data.resources
          container.removeAttr("data-waiting")
        )

  renderPagination: (collection) ->
    pagination = collection.pagination || {}

    if pagination.total_pages > 1
      pagination.resources_path = collection.url
      pagination.pages          = []

      if (pagination.current_page > 1)
        pagination.paginatePrev = (pagination.current_page - 1)

      if (pagination.current_page < pagination.total_pages)
        pagination.paginateNext = (pagination.current_page + 1)

      # builder pages
      for number in [1..pagination.total_pages]
        page         = {}
        page.liKlass = "active" if pagination.current_page is number
        page.text    = number
        page.path    = "#{pagination.resources_path}?page=#{number}"
        pagination.pages.push(page)

      @$("#pagination-container").html(
        $("#backboneTemplatesPagination").tmpl(pagination)
      )

  # Remove Callbacks in beforeRemove() function if needed
  # ==========================================================
  remove: ->
    @beforeRemove()
    super()

  # I18n support
  t: (route = "") ->
    Modules.I18n.t route

  # Falsh Messages
  flash: (type, messages = "") ->
    if _.include <%= js_app_name %>.Config.flashes, type
      if _.isString messages
        messages = {messages: [{message: messages}]}

      flashTemplate = "render_#{type}".toCamelize("lower")
      <%= js_app_name %>.Helpers[flashTemplate]? messages

