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
