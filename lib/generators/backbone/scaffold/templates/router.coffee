class <%= router_namespace %>Router extends <%= js_app_name %>.Routers.BaseRouter
  initialize: (options) ->
    @<%= plural_model_name %> = new <%= collection_namespace %>Collection()
    @<%= plural_model_name %>.reset options.<%= plural_model_name %>

  routes:
    "/new"      : "new"
    "/index"    : "index"
    "/:id/edit" : "edit"
    "/:id"      : "show"
    ".*"        : "index"

  new: ->
    @newView = new <%= "#{view_namespace}.NewView(collection: @#{plural_model_name})" %>
    $("#<%= plural_name %>").html(@new<%= backbone_class_name %>View.render().el)

  index: ->
    @indexView = new <%= "#{view_namespace}.IndexView(#{plural_model_name}: @#{plural_model_name})" %>
    $("#<%= plural_name %>").html(@indexView.render().el)

  show: (id) ->
    <%= singular_name %> = @<%= plural_model_name %>.get(id)

    if <%= singular_name %>?
      <%= singular_name %>.setAllValues()

      @showView = new <%= "#{view_namespace}.ShowView(model: #{singular_name})" %>
      $("#<%= plural_name %>").html(@showView.render().el)
    else @resourceNotFound()

  edit: (id) ->
    <%= singular_name %> = @<%= plural_model_name %>.get(id)

    if <%= singular_name %>?
      <%= singular_name %>.setAllValues()

      @editView = new <%= "#{view_namespace}.EditView(model: #{singular_name})" %>
      $("#<%= plural_name %>").html(@editView.render().el)
    else @resourceNotFound()
