<%= view_namespace %> ||= {}

class <%= view_namespace %>.<%= singular_name.camelize %>View extends Backbone.View
  template: (data) -> $("#<%= tmpl singular_name %>").tmpl(data)

  events:
    "click .destroy" : "destroy"

  tagName: "tr"

  destroy: () ->
    @model.destroy()
    this.remove()

    return false

  render: ->
    $(this.el).html(@template(@model.toJSON() ))
    return this
