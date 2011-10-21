<%= view_namespace %> ||= {}

class <%= view_namespace %>.IndexView extends <%= js_app_name %>.Views.BaseView
  template: (data) -> $("#<%= tmpl 'index' %>").tmpl(data)

  initialize: () ->
    _.bindAll(this, 'addOne', 'addAll', 'render')
    @options.<%= plural_model_name %>.bind('reset', @addAll)

  events:
    _.extend( _.clone(@__super__.events),
     {}
    )

  addAll: () ->
    @$("#<%= plural_name %>-table tbody").empty()
    @renderPagination(@options.<%= plural_model_name %>) if @options.<%= plural_model_name %>.pagination?
    @options.<%= plural_model_name %>.each(@addOne)

  addOne: (<%= singular_model_name %>) ->
    view = new <%= view_namespace %>.<%= singular_name.camelize %>View({model : <%= singular_model_name %>})
    @$("#<%= plural_name %>-table tbody").append(view.render().el)

  render: ->
    $(@el).html(@template(<%= plural_model_name %>: @options.<%= plural_model_name %>.toJSON() ))
    @addAll()

    return this

  remove: ->
    @options.<%= plural_model_name %>.unbind('reset', @addAll)
    super()

  pagination: (e) ->
    super(e, @options.<%= plural_model_name %>)
