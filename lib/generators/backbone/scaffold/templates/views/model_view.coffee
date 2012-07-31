<%= view_namespace %> ||= {}

class <%= view_namespace %>.<%= singular_name.camelize %>View extends <%= js_app_name%>.Views.BaseView
  template: (data) -> $("#<%= tmpl singular_name %>").tmpl(data)

  tagName: "tr"

  events:
    _.extend( _.clone(@__super__.events),
     {}
    )

  render: ->
    $(@el).html( @template( @model.toJSON(true, true) ) )
    return this
