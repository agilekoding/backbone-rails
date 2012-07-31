class <%= js_app_name %>.Collections.BaseCollection extends Backbone.Collection

  # The JSON representation of a Collection is an array of the
  # models' attributes.
  toJSON : (includeRelations = false, includeCalculated = false) ->
    @map( (model) -> model.toJSON(includeRelations, includeCalculated) )

  # When you have more items than you want to add or remove individually,
  # you can reset the entire set with a new list of models, without firing
  # any `added` or `removed` events. Fires `reset` when finished.
  reset: (models = [], options = {}) ->
    @pagination = models.pagination if models.pagination?
    models      = models.resources if models.resources?

    @each @_removeReference
    @_reset()
    @add models, silent: true
    @trigger('reset', this, options) if (!options.silent)
    this

