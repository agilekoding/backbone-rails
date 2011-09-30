<%= view_namespace %> ||= {}

class <%= view_namespace %>.<%= @action.camelize %>View extends Backbone.View
  template: () -> $("#<%= tmpl @action %>").tmpl()

  render: ->
    $(@el).html(@template())
    @
