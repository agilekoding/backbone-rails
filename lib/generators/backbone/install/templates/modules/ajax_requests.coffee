Modules.AjaxRequests =

  instanceMethods:

    getJSON: (url, params = {}) ->
      <%= js_app_name %>.Helpers.jsonData(url, params)

    doAjax: (settings = {}) ->
      settings = _.extend {
        error: (jqXHR) =>
          if /^\</.test(jqXHR.responseText) then errorsMessages = null
          else errorsMessages = $.parseJSON(jqXHR.responseText)
          errorsMessages = errorsMessages.errors if errorsMessages.errors?
          @renderErrors(null,  errorsMessages)
      }, settings

      <%= js_app_name %>.Helpers.ajax(settings)

    # Remote Forms
    remoteForm: (e, settings = {}) ->
      e.preventDefault()
      e.stopPropagation()

      form = $(e.currentTarget)

      if @isValidForm(form) is false
        @renderErrors(null, @_formErrors)
      else
        url  = form.prop("action")

        if url?
          return false unless @allowAction(form)
          type  = form.prop("method")   || "GET"
          data  = form.serializeArray() || {}
          files =  $(":file", form)

          if form.prop("enctype") is "multipart/form-data" and files.length > 0
            settings = _.extend { files: files, iframe: true, processData: false }, settings

          settings = _.extend { url: url, type: type, data: data }, settings
          @doAjax settings

    _validateForm: (form) ->
      return false unless form.is("form")

      attrs       = {}
      validations = {}
      inputs      = form.find("input[data-validations]")

      inputs.each ->
        input            = $(this)
        value            = input.val()
        name             = input.attr("name").replace("[", ".").replace("]", "")
        validates        = {}
        arrayValidations = input.attr("data-validations").split(" ")

        for validation in arrayValidations
          validates[validation] = true

        attrs[name]       = value
        validations[name] = validates
      @_formErrors = @_validates(attrs, validations)

    isValidForm: (form) ->
       result = @_validateForm(form)
       return false if result is false
       _.isEmpty result

    _getInputName: (el) ->
      nestedName = el.attr("name").replace("[]", "")
      nesteds    = nestedName.split("[")
      for nested, i in nesteds
        nesteds[i] = nested.replace("]", "")
      nesteds[nesteds.length-1]
