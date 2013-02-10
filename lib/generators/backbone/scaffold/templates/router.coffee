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
    @new<%= backbone_class_name %>View = new <%= "#{view_namespace}.NewView(collection: @#{plural_model_name})" %>
    $("#<%= plural_name %>").html(@new<%= backbone_class_name %>View.render().el)

  index: ->
    @index<%= backbone_class_name %>View = new <%= "#{view_namespace}.IndexView(#{plural_model_name}: @#{plural_model_name})" %>
    $("#<%= plural_name %>").html(@index<%= backbone_class_name %>View.render().el)

  show: (id) ->
    <%= singular_name %> = @<%= plural_model_name %>.get(id)

    if <%= singular_name %>?
      <%= singular_name %>.setAllValues()

      @show<%= backbone_class_name %>View = new <%= "#{view_namespace}.ShowView(model: #{singular_name})" %>
      $("#<%= plural_name %>").html(@show<%= backbone_class_name %>View.render().el)
    else @resourceNotFound()

  edit: (id) ->
    <%= singular_name %> = @<%= plural_model_name %>.get(id)

    if <%= singular_name %>?
      <%= singular_name %>.setAllValues()

      @edit<%= backbone_class_name %>View = new <%= "#{view_namespace}.EditView(model: #{singular_name})" %>
      $("#<%= plural_name %>").html(@edit<%= backbone_class_name %>View.render().el)
    else @resourceNotFound()


