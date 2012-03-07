Modules.Validations =

  instanceMethods:

    _validates: (attrs, validates = {}) ->
      resultMessage = {}
      messages      = Modules.I18n.messages()?.errorsMessages || {}

      # Each for attributes of the model
      _.each(attrs, (attrValue, attrKey) =>

        for key, validation of validates[attrKey]
          appliedValidations = true
          action             = validation.on

          appliedValidations = false if validates[attrKey].if is false

          if _.isFunction @isNew
            if @isNew() is true and action is "update"
              appliedValidations = false

            if @isNew() is false and action is "create"
              appliedValidations = false

          if appliedValidations is true

            isEmpty = _.isEmpty( $.trim( attrValue ) )


            switch key
              when "presence"
                if isEmpty
                  (resultMessage[attrKey] ||= []).push(messages.blank)

              when "numericality"
                if isEmpty is false and  /^(\-)?\d+(\.\d+)?$/.test( attrValue ) is false
                  (resultMessage[attrKey] ||= []).push(messages.not_a_number)

              when "email"
                if isEmpty is false and  /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/.test( attrValue ) is false
                  (resultMessage[attrKey] ||= []).push(messages.invalid_email)

              when "rfc"
                if isEmpty is false and  /^([A-Z|a-z|&amp;]{3}\d{2}((0[1-9]|1[012])(0[1-9]|1\d|2[0-8])|(0[13456789]|1[012])(29|30)|(0[13578]|1[02])31)|([02468][048]|[13579][26])0229)(\w{2})([A-Z|a-z|0-9])$|^([A-Z|a-z]{4}\d{2}((0[1-9]|1[012])(0[1-9]|1\d|2[0-8])|(0[13456789]|1[012])(29|30)|(0[13578]|1[02])31)|([02468][048]|[13579][26])0229)((\w{2})([A-Z|a-z|0-9])){0,3}$/.test( attrValue ) is false
                  (resultMessage[attrKey] ||= []).push(messages.invalid)

              when "zip_code"
                if isEmpty is false and  /^\d{5}$/.test( attrValue ) is false
                  (resultMessage[attrKey] ||= []).push(messages.invalid)

              when "length"
                if isEmpty is false
                  min        = validation.min
                  max        = validation.max
                  attrLength = (attrValue || "").length

                  if (min? and attrLength < min)
                    if min is 1 then lengthMessage = "one" else lengthMessage = "other"
                    message = (messages.too_short?[lengthMessage] || "").replace("%{count}", min)
                    (resultMessage[attrKey] ||= []).push(message)

                  else if (max? and attrLength > max)
                    if max is 1 then lengthMessage = "one" else lengthMessage = "other"
                    message = (messages.too_long?[lengthMessage] || "").replace("%{count}", max)
                    (resultMessage[attrKey] ||= []).push(message)

              when "equalTo"
                unless attrValue is @get(validation)
                  message = (messages.equal_to || "").replace("%{count}", @humanAttributeName(validation))
                  (resultMessage[attrKey] ||= []).push(message)

              else false
      )
      resultMessage
