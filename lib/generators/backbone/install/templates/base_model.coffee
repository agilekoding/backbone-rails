class <%= js_app_name %>.Models.BaseModel extends Backbone.Model

  initialize: () ->
    _.each(@hasMany,
      (relation) =>
        @[relation.key] = new <%= js_app_name %>.Collections[relation.collection]
        @[relation.key].url = "#{@url()}/#{relation.key}" unless @isNew()
        @[relation.key].reset @attributes[relation.key] if @attributes[relation.key]?
    )

  toJSON: () ->
    json = @attributes
    json["#{@paramRoot}_cid"] = "backboneCid_#{@cid}" if @includeCidInJson
    _.each(@hasMany,
      (relation) =>
        json["#{relation.key}_attributes"] = @[relation.key].toJSON() if @[relation.key]?
        delete json[relation.key] if json[relation.key]?
    )
    json


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

  hasMany: []

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
