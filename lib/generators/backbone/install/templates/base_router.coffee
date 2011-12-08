class <%= js_app_name %>.Routers.BaseRouter extends Backbone.Router

  # Manually bind a single named route to a callback. For example:
  #
  # @route('search/:query/p:num', 'search', (query, num) ->
  #   ...
  #

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

      this)
    )

  beforeFilter: ->

  removeViews: (name) ->
    @["#{name}_view"].remove() if @["#{name}_view"]? # index_view
    @["#{name}View"].remove()  if @["#{name}View"]?  # customNameView

  resetModelsWithoutSaving: () ->
    _.each(@_editedModels, (model) ->
      model.resetToOriginValues()
    )
    @_editedModels = []

  resourceNotFound: ->
    @flash "warning", @t("errors.not_found")
    window.location.hash = "/index"

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
