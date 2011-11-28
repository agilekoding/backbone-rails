Modules.I18n =
  locale: <%= js_app_name %>.Config.default_locale

  hash: -> <%= js_app_name %>.Locales[@locale] || {}

  t: (route = "") ->
    hash = @hash()
    keys = route.split(".")

    for key in keys
      if hash[key]? then hash = hash[key]
      else hash = key

    hash
