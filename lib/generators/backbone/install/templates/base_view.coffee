class <%= js_app_name %>.Views.BaseView extends Backbone.View

  # Defaults Events
  events:
    "click .destroy" : "destroy"
    "click div.pagination a" : "pagination"

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

  # Errors
  # ________________________________________________________________________
  renderErrors: (model, errors) ->
    fullErrors = {}
    _.each(errors, (messages, key) ->
      name = $('label[for="' + model.paramRoot + '_' + key + '"]').text() || key
      for message in messages
        (fullErrors.errors ||= []).push({name: name, message: message})
    )
    <%= js_app_name %>.Helpers.renderErrors(fullErrors)

  # Pagination
  # ________________________________________________________________________
  pagination: (e, collection) ->
    e.preventDefault()
    link = $(e.currentTarget)
    li   = link.closest("li")

    unless li.is(".active, .prev.disabled, .next.disabled")
      href = link.attr("href")
      data = <%= js_app_name %>.Helpers.jsonData href
      collection.pagination = data.pagination
      collection.reset data.resources

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
        page = {}
        page.liKlass = "active" if pagination.current_page is number
        page.text = number
        page.path   = "#{pagination.resources_path}?page=#{number}"
        pagination.pages.push(page)

      @$("#pagination-container").html(
        $("#backboneTemplatesPagination").tmpl(pagination)
      )
