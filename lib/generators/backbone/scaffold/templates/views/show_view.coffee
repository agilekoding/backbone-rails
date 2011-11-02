<%= view_namespace %> ||= {}

class <%= view_namespace %>.ShowView extends <%= js_app_name %>.Views.BaseView
  template: (data) -> $("#<%= tmpl 'show' %>").tmpl(data)

  events:
    _.extend( _.clone(@__super__.events),
      {}
    )

  render: ->
    $(@el).html( @template( @model.toJSON(true) ) )
    return this

  destroy: (e) ->
    super(e, success: () -> window.location.hash = "")
