class <%= js_app_name %>.Models.BaseModel extends Backbone.Model

  initialize: (attributes, options) ->
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
      if relation.collection?
        # Create a new collection object if not exist
        unless @[key]?
          @[key] = new <%= js_app_name %>.Collections[relation.collection]
          @[key].url = "#{@collectionRoute}/#{attributes.id}/#{key}" unless @isNew()

        @[key].reset attributes[key] if attributes[key]?
    )

    # Call After Initialize Callback
    @afterInitialize()

  toJSON: ( includeRelations = false ) ->
    json = _.clone @attributes

    if includeRelations is true
      json["#{@paramRoot}_cid"] = "backboneCid_#{@cid}"

    # belongsTo
    _.each(@belongsTo,
      (relation, key) =>
        relation = @buildBelonsToRelation(relation, key)

        # include nesteds attributes for save with AJAX
        if includeRelations is false
          if @[key]? and relation.isNested is true
            if relation.isPolymorphic isnt true
              json["#{key}_attributes"] = @[key].toJSON(includeRelations)
          delete json[key]

        # include all values to use in Show view for example
        else if @[key]?
          json[key] = @[key].toJSON(includeRelations)

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
            json["#{key}_attributes"] = @[key].toJSON(includeRelations)
          delete json[key]
        else if @[key]?
          json[key] = @[key].toJSON(includeRelations)
    )

    # Attributes that are eliminated are not part of the model
    # only used to display information with some custom format
    if includeRelations is false
      _.each(@removeWhenSaving, (value) ->
        delete json[value]
      )


    json

  prepareToEdit: () ->
    window.router._editedModels ||= []
    index = _.indexOf(window.router._editedModels, @)
    if index is -1
      @_originalAttributes = _.clone( @toJSON() )
      window.router._editedModels.push(@)

  resetToOriginValues: () ->
    @set @_originalAttributes

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
            url  = "/#{relation.route}/#{newValue}"
            data = <%= js_app_name %>.Helpers.jsonData(url)

            # Set values in association model
            @[key].set(data) if data?

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
      # If route is not defined it's taken from model collectionRoute
      unless relation.route?
        relation.route = <%= js_app_name %>.Models[relation.model].collectionRoute

      # If foreignKey is not defined it's taken from model paramRoot more "_id"
      unless relation.foreignKey?
        relation.foreignKey = "#{<%= js_app_name %>.Models[relation.model].paramRoot}_id"

    relation


  polymorphicRelation: (relation, key) ->
    polymorphicType     = "#{key}_type"
    relation.foreignKey = "#{key}_id"

    if (modelName = @get(polymorphicType))?
      relation.route = <%= js_app_name %>.Models[modelName].collectionRoute
      relation.model = modelName

    relation

  resetRelations: (attributes) ->
    # belongsTo
    _.each(@belongsTo,
      (relation, key) =>
        values   = attributes[key]
        relation = @buildBelonsToRelation(relation, key)
        if values? and relation.isNested is true
          @[key]   = new <%= js_app_name %>.Models[relation.model] values
    )
    # hasMany
    _.each(@hasMany,
      (relation, key) =>
        values = attributes[key]
        @[key].url = "#{@collectionRoute}/#{@get('id')}/#{key}" unless @isNew()
        @[key].reset values if values?
    )


  validates: (attrs, validates = {}) ->
    resultMessage = {}
    messages = <%= js_app_name %>.Helpers.errorsMessages

    _.each(attrs, (value, key) =>
      values = _.compact( (validates[key] ||= "").split(" ") )

      for validation in values
        appliedValidations = true
        value              = validation.split(":")[0]
        action             = validation.split(":")[1]

        if @isNew() is true and action is "onUpdate"
          appliedValidations = false

        if @isNew() is false and action is "onCreate"
          appliedValidations = false

        if appliedValidations is true

          switch value
            when "presence"
              if _.isEmpty( $.trim( attrs[key] ) )
                (resultMessage[key] ||= []).push(messages.blank)

            when "numericality"
              unless (/^\d+\.?\d+$/.test( attrs[key] ) )
                (resultMessage[key] ||= []).push(messages.not_a_number)

            when "email"
              unless ( /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/.test( attrs[key] ) )
                (resultMessage[key] ||= []).push(messages.invalid_email)

            when "rfc"
              unless ( /^([A-Z|a-z|&amp;]{3}\d{2}((0[1-9]|1[012])(0[1-9]|1\d|2[0-8])|(0[13456789]|1[012])(29|30)|(0[13578]|1[02])31)|([02468][048]|[13579][26])0229)(\w{2})([A-Z|a-z|0-9])$|^([A-Z|a-z]{4}\d{2}((0[1-9]|1[012])(0[1-9]|1\d|2[0-8])|(0[13456789]|1[012])(29|30)|(0[13578]|1[02])31)|([02468][048]|[13579][26])0229)((\w{2})([A-Z|a-z|0-9])){0,3}$/.test( attrs[key] ) )
                (resultMessage[key] ||= []).push(messages.invalid)

            when "zip_code"
              unless ( /^\d{5}$/.test( attrs[key] ) )
                (resultMessage[key] ||= []).push(messages.invalid)

            when "equalTo"
              unless attrs[key] is @get(action)
                message = "#{messages.equal_to} #{@humanAttributeName(action)}"
                (resultMessage[key] ||= []).push(message)

            else false
    )

    if _.isEmpty(resultMessage)
      delete @errors
      null
    else
      @attributes = _.extend(@attributes, attrs)
      @errors = resultMessage

  isValid: () ->
    if @validate(@attributes)? then false else true

  includeCidInJson: false

  # Relations
  hasMany: {}

  belongsTo: {}

  delegates: {}

  removeWhenSaving: []

  # Callbacks
  afterSave: {}

  afterInitialize: () ->

  modelName: () ->
    @paramRoot

  humanName: () ->
    name = <%= js_app_name %>.Helpers.activerecord.models[@paramRoot]
    if name? then name else @paramRoot

  humanAttributeName: (name) ->
    modelAttributes = <%= js_app_name %>.Helpers.activerecord.attributes[@paramRoot]
    if modelAttributes?
      attribute = modelAttributes[name]
      attributeName = if attribute? then attribute else name
    else
      attributeName = name

    attributeName
