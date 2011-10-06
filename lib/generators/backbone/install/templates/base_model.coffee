class <%= js_app_name %>.Models.BaseModel extends Backbone.Model

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
