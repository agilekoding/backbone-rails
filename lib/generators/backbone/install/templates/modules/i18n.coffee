Modules.I18n =

  locale   : <%= js_app_name %>.Config.locale()

  messages : ->
    <%= js_app_name %>.Locales[@locale]

  t: (route = "", options = {}) ->
    messages = @messages() || {}
    keys     = route.split(".")

    for key in keys
      if messages[key]? then messages = messages[key]
      else messages = key

    messages = messages.supplant(options) unless _.isEmpty(options)
    messages

  instanceMethods:

    t: (route = "", options = {}) ->
      Modules.I18n.t route, options

    # Falsh Messages
    flash: (type, messages = "", alertsContainer = "#alerts_container") ->
      if _.include <%= js_app_name %>.Config.flashes, type
        if _.isString messages
          messages = {messages: [{message: messages}]}

        flashTemplate = "render_#{type}".toCamelize("lower")
        <%= js_app_name %>.Helpers[flashTemplate]? messages, alertsContainer
