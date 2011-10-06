<%= view_namespace %> ||= {}

class <%= view_namespace %>.NewView extends <%= js_app_name %>.Views.BaseView
  template: (data) -> $("#<%= tmpl 'new' %>").tmpl(data)

  initialize: (options) ->
    super(options)
    @model = new @collection.model()
    @model.bind("error", @renderErrors)

  events:
    _.extend( _.clone(@__super__.events),
      "submit #new-<%= singular_name %>": "save"
    )

  render: ->
    $(@el).html( @template( @model.toJSON() ) )
    this.$("form#new-<%= singular_name %>").backboneLink(@model)
    return this
