class <%= js_app_name %>.Models.BaseModel extends Backbone.Model

  initialize: () ->
    # Callbacks
    @bind("afterSave", (model, jqXHR) ->
      _.each(@afterSave, (callback, key) -> callback(model, jqXHR) )
    )

    # belongsTo
    @setBelongsTo()
    _.each(@belongsTo, (relation, key) => @bind("change:#{relation.foreignKey}", () -> @setBelongsTo(key) ) )

    # hasMany
    _.each(@hasMany, (relation, key) =>
      if relation.collection?
        @[key] = new <%= js_app_name %>.Collections[relation.collection]
        @[key].url = "#{@url()}/#{key}" unless @isNew()
        @[key].reset @attributes[key] if @attributes[key]?
    )

  toJSON: () ->
    json = @attributes
    json["#{@paramRoot}_cid"] = "backboneCid_#{@cid}" if @includeCidInJson
    _.each(@hasMany,
      (relation, key) =>
        json["#{key}_attributes"] = @[key].toJSON() if @[key]?
        delete json[key] if json[key]?
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

  setBelongsTo: (attribute) ->
    if attribute?
      relation = @belongsTo[attribute]
      if @get(relation.foreignKey) and relation.route? and relation.model?
        url  = "/#{relation.route}/#{@get(relation.foreignKey)}"
        data = <%= js_app_name %>.Helpers.jsonData(url)
        if @[attribute]? then @[attribute].set(data)
        else @[attribute] = new <%= js_app_name %>.Models[relation.model] data
    else
      _.each(@belongsTo, (relation, key) =>
        if @get(relation.foreignKey) and relation.route? and relation.model?
          url  = "/#{relation.route}/#{@get(relation.foreignKey)}"
          data = <%= js_app_name %>.Helpers.jsonData(url)
          if @[key]? then @[key].set(data)
          else @[key] = new <%= js_app_name %>.Models[relation.model] data
      )

  validates: (attrs, validates = {}) ->
    resultMessage = {}
    messages = <%= js_app_name %>.Helpers.errorsMessages

    _.each(attrs, (value, key) ->
      values = _.compact( (validates[key] ||= "").split(" ") )

      for value in values

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

  # Callbacks
  afterSave: {}

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
