class <%= js_app_name %>.Collections.BaseCollection extends Backbone.Collection

  # The JSON representation of a Collection is an array of the
  # models' attributes.
  toJSON: ( includeRelations = false ) ->
    @map( (model) -> model.toJSON(includeRelations) )
