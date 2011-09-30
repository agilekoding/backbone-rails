class <%= router_namespace %>Router extends Backbone.Router
  initialize: (options) ->
    @<%= plural_model_name %> = new <%= collection_namespace %>Collection()
    @<%= plural_model_name %>.reset options.<%= plural_model_name %>

  routes:
    "/new"      : "new<%= class_name %>"
    "/index"    : "index"
    "/:id/edit" : "edit"
    "/:id"      : "show"
    ".*"        : "index"

  new<%= class_name %>: ->
    @new_view = new <%= "#{view_namespace}.NewView(collection: @#{plural_name})" %>
    $("#<%= plural_name %>").html(@new_view.render().el)

  index: ->
    @index_view = new <%= "#{view_namespace}.IndexView(#{plural_name}: @#{plural_name})" %>
    $("#<%= plural_name %>").html(@index_view.render().el)

  show: (id) ->
    <%= singular_name %> = @<%= plural_name %>.get(id)

    @show_view = new <%= "#{view_namespace}.ShowView(model: #{singular_name})" %>
    $("#<%= plural_name %>").html(@show_view.render().el)

  edit: (id) ->
    <%= singular_name %> = @<%= plural_name %>.get(id)

    @edit_view = new <%= "#{view_namespace}.EditView(model: #{singular_name})" %>
    $("#<%= plural_name %>").html(@edit_view.render().el)
