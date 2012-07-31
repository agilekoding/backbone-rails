class <%= js_app_name %>.Routers.BaseRouter extends Backbone.Router

  _.extend @, Modules.Inheritance

  @include Modules.I18n

  # Manually bind a single named route to a callback. For example:
  # @route('search/:query/p:num', 'search', (query, num) ->

  route : (route, name, callback) ->
    Backbone.history || (Backbone.history = new Backbone.History)

    route = @._routeToRegExp(route) if (!_.isRegExp(route))

    Backbone.history.route(route, _.bind(
      (fragment) ->
        args = this._extractParameters(route, fragment)

        @removeViews(name)
        @resetModelsWithoutSaving()
        @beforeFilter()

        callback.apply(this, args)
        @trigger.apply(this, ['route:' + name].concat(args))

        @renderPageTitle()
      this)
    )

  beforeFilter: ->

  removeViews: (name) ->
    @["#{name}View"]?.remove()   # indexView
    true

  resetModelsWithoutSaving: () ->
    _.each(@_editedModels, (model) ->
      model.resetToOriginValues()
    )
    @_editedModels = []

  renderPageTitle: ->
    title_page = $("title").text()
    title_h1   = $.trim $('.container h1:first').text()
    title_page = title_page.split('|')
    $('title').text("#{title_h1} | #{title_page[1]}")

  resourceNotFound: (url = "/index", showFlash = true) ->
    @flash "warning", @t("errors.not_found") if showFlash
    window.location.hash = url
