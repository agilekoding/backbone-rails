<%= view_namespace %> ||= {}

class <%= view_namespace %>.ShowView extends Backbone.View
  template: (data) -> $("#<%= tmpl 'show' %>").tmpl(data)

  render: ->
    $(this.el).html(@template(@model.toJSON() ))
    return this
