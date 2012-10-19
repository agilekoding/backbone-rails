class <%= js_app_name %>.Models.BaseModel extends Backbone.Model

  _.extend @, Modules.Inheritance

  @include Modules.Validations

  constructor: (attributes = {}, options) ->

    # Default Logic in the constructor of Backbone Model
    # =========================================================
    if defaults = @defaults
      defaults   = defaults.call(this) if _.isFunction(defaults)
      attributes = _.extend({}, defaults, attributes)

    @attributes          = {}
    @_escapedAttributes  = {}
    @cid                 = _.uniqueId('c')
    @set(attributes, {silent : true})
    @_changed            = false
    @_previousAttributes = _.clone(@attributes)
    @collection = options.collection if (options && options.collection)
    # =========================================================

    # Clone de original attributes
    attributes = _.extend({}, _.clone(attributes))

    # Callbacks
    @bind("afterSave", (model, jqXHR) ->
      _.each(@afterSave, (callback, key) -> callback?(model, jqXHR) )
    )

    # belongsTo
    @setBelongsTo(attributes, null)

    _.each(@belongsTo, (relation, key) =>
      relation = @buildBelonsToRelation(relation, key)
      @bind("change:#{relation.foreignKey}", () ->
        @setBelongsTo({}, key)
      )
    )
    # hasMany
    _.each(@hasMany, (relation, key) =>
      relation.collection ||= "#{key.toCamelize()}Collection"
      # Create a new collection object if not exist
      unless @[key]?
        @[key] = new <%= js_app_name %>.Collections[relation.collection]
        @[key].url = "#{@urlRoot}/#{attributes.id}/#{key}" unless @isNew()

      @[key].reset attributes[key] if attributes[key]?
    )

    @initialize(attributes, options)

  calculatedAttributes: {}

  save: ->
    $('.alert-message').remove()
    super(arguments...)

  updateAttribute: (attribute, value, options = {}) ->
    attrs            = {}
    attrs[attribute] = value
    return false if !@set(attrs)

    data = {}
    if @paramRoot? then data[@paramRoot] = attrs
    else data = attrs

    _.extend data, {template: "base"}

    settings =
      url    : "#{@urlRoot}/#{@get('id')}"
      type   : "PUT"
      data   : data

    _.extend settings, options
    <%= js_app_name %>.Helpers.ajax(settings)

  updateAttributes: (attrs, options = {}) ->
    return false if !@set(attrs)

    data = {}
    if @paramRoot? then data[@paramRoot] = attrs
    else data = attrs

    _.extend data, {template: "base"}

    settings =
      url    : "#{@urlRoot}/#{@get('id')}"
      type   : "PUT"
      data   : data

    _.extend settings, options
    <%= js_app_name %>.Helpers.ajax(settings)

  get : ( key ) ->
    that = @

    if @calculatedAttributes[key]
      value = @calculatedAttributes[key]

      if typeof value != 'undefined'
        return value()

    # fall back to the default backbone behavior
    super(key)

  backboneCid: -> "backboneCid_#{@cid}"

  toJSON: ( includeRelations = false, includeCalculated = false ) ->
    json = _.clone @attributes

    if includeRelations is true
      json["#{@paramRoot}_cid"] = "backboneCid_#{@cid}"

    if includeCalculated is true
      _.each(@calculatedAttributes, (attribute, key) =>
        json[key] = attribute(@)
      )

    # belongsTo
    _.each(@belongsTo,
      (relation, key) =>
        relation = @buildBelonsToRelation(relation, key)

        # include nesteds attributes for save with AJAX
        if includeRelations is false
          if @[key]? and relation.isNested is true
            if relation.isPolymorphic isnt true
              json["#{key}_attributes"] = @[key].toJSON(includeRelations, includeCalculated)

          delete json[key]

        # include all values to use in Show view for example
        else if @[key]?
          json[key] = @[key].toJSON(includeRelations, includeCalculated)

          # include delegates
          delegate = @delegates[key] || {}
          _.each(delegate.attributes, (name) ->
            if delegate.prefix is true then keyName = "#{key}_#{name}"
            else keyName = name
            json[keyName] = json[key][name]
          )

    )
    # hasMany
    _.each(@hasMany,
      (relation, key) =>
        if includeRelations is false

          if @[key]? and relation.isNested is true
            json["#{key}_attributes"] = @[key].toJSON(includeRelations, includeCalculated)

          delete json[key]

        else if @[key]?
          json[key] = @[key].toJSON(includeRelations, includeCalculated)
    )

    # Attributes that are eliminated are not part of the model
    # only used to display information with some custom format
    if includeRelations is false
      _.each(@removeWhenSaving, (value) ->
        delete json[value]
      )

      # Type attribute is removed because are used by rails for inheritance
      delete json["type"]

      # Attributes with null value are eliminated
      for _key, _value of json
        if _value is null and @hasChanged(_key) is false
          delete json[_key]

    json

  setBelongsTo: (attributes, callbackKey) ->
    # For reload association object when foreignKey has changed
    if callbackKey?
      relation = @belongsTo[callbackKey]
      @createBelongsToRelation(attributes, relation, callbackKey, callbackKey)

    # For load association when and models is instantiated
    else
      _.each(@belongsTo, (relation, key) =>
        @createBelongsToRelation(attributes, relation, key, callbackKey)
      )

  createBelongsToRelation: (attributes, relation, key, callbackKey) ->
    relation = @buildBelonsToRelation(relation, key)

    if relation.model?

      unless @[key]?
        @[key] = new <%= js_app_name %>.Models[relation.model] attributes[key]

      # Retrieve values from database if foreignKey has changed
      else if callbackKey? and relation.isNested isnt true

        if newValue = @get(relation.foreignKey)
          if newValue isnt @[key].get("id")
            url      = "/#{relation.route}/#{newValue}"
            template = relation.template || "base"
            data     = <%= js_app_name %>.Helpers.jsonData url, api_template: template
            #@[key].set(data, {silent: true}) if data?
            @[key].resetRelations data

        # clear attributes if foreignKey is null
        else @[key].clear silent: true

    else
      # Create a new Backbone Model for use toJSON function
      @[key] = new Backbone.Model

  buildBelonsToRelation: (relation, key) ->
    relation = _.clone relation

    # When belongsTo is a polymorphic association
    if relation.isPolymorphic is true
      relation = @polymorphicRelation(relation, key)

    else
      # If route is not defined it's taken from model urlRoot
      unless relation.route?
        relation.route = <%= js_app_name %>.Models[relation.model].urlRoot

      # If foreignKey is not defined it's taken from model paramRoot more "_id"
      unless relation.foreignKey?
        relation.foreignKey = "#{<%= js_app_name %>.Models[relation.model].paramRoot}_id"

    relation

  polymorphicRelation: (relation, key) ->
    polymorphicType     = "#{key}_type"
    relation.foreignKey = "#{key}_id"

    if (modelName = @get(polymorphicType))?
      relation.route = <%= js_app_name %>.Models[modelName].urlRoot
      relation.model = modelName

    relation

  prepareToEdit: () ->
    window.router._editedModels ||= []
    index = _.indexOf(window.router._editedModels, @)
    if index is -1
      @_originalAttributes = _.clone( @toJSON() )
      window.router._editedModels.push(@)

  resetToOriginValues: () ->
    @set @_originalAttributes

  setAllValues: (url = @url()) ->
    resettable = if _.isFunction(@isResettable) then @isResettable() else @isResettable
    if resettable is true and @allValuesSeted is false
      data = <%= js_app_name %>.Helpers.jsonData url

      if data?
        @resetRelations data, true
        @allValuesSeted = true

  allValuesSeted: false

  resetRelations: (data, setAllValues = false) ->
    # Self Attributes
    _.each(data, (value, key) =>
      if !@belongsTo[key]? or !@hasMany[key]?
        @attributes[key] = data[key]
        @id = data[key] if key is "id"
    )

    # belongsTo
    _.each(@belongsTo,
      (relation, key) =>
        values   = data[key]
        relation = @buildBelonsToRelation(relation, key)
        if values? and ( relation.isNested is true or relation.resettable is true or setAllValues is true)
          @[key] = new <%= js_app_name %>.Models[relation.model] values
    )
    # hasMany
    _.each(@hasMany,
      (relation, key) =>
        values = data[key]
        @[key].url = "#{@urlRoot}/#{@get('id')}/#{key}" unless @isNew()
        @[key].reset values if values?
    )


  validates: (attrs, validates = {}) ->
    resultMessage = @_validates attrs, validates

    if _.isEmpty(resultMessage) then null
    else
      @attributes = _.extend(@attributes, attrs)
      @errors     = resultMessage

  isValid: () ->
    resultValidation = @validate(@attributes) || {}

    # Run HasMany validations
    for key, value of @hasMany when value.isNested is true
      @[key].each((model) ->
        nestedValidation = model.validate(model.attributes) || {}
        resultValidation["#{key}.#{_key}"] = _value for _key, _value of nestedValidation
      )

    # Run BelongsTo validations
    for key, value of @belongsTo when value.isNested is true
      model = @[key]
      nestedValidation = model.validate(model.attributes) || {}
      resultValidation["#{key}.#{_key}"] = _value for _key, _value of nestedValidation

    if _.isEmpty resultValidation then true
    else @errors = resultValidation

  includeCidInJson: false

  # Relations
  hasMany: {}

  belongsTo: {}

  delegates: {}

  removeWhenSaving: []

  isResettable: ->
    _.isEmpty(@hasMany) is false

  resettableAttributes: []

  # Callbacks
  afterSave: {}

  # I18n support
  modelName: () ->
    @paramRoot

  humanName: () ->
    Modules.I18n.t "activerecord.models.#{@paramRoot}"

  humanAttributeName: (name) ->
    if name.split(".").length is 1
      Modules.I18n.t "activerecord.attributes.#{@paramRoot}.#{name}"
    else Modules.I18n.t "#{name}"
