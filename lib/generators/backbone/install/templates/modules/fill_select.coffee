Modules.FillSelect =

  # Callbacks
  # ==========================================================
  #beforeInitialize: ->

  #afterInitialize: ->

  #beforeRemove: ->

  instanceMethods:

    fill_select: (options) ->
      return if !options.url or !options.target

      findTarget.call(this, options)
      resetDependentLists(options)

      if isValidUrl(options.url)

        @doAjax
          url  : options.url
          data :
            api_template : (options.api_template || "base")

          success : (data) =>
            renderOptions.call(this, options, data)


  # Class Methods
  # ================================================================

  #classMethods:

    #class_method: ->


# Private Methods
# ================================================================
renderOptions = (options, data) ->
  target = options.target

  options.value      ||= "id"
  options.name       ||= "name"
  options.resources  ||= "resources"

  target.append newOption("", @t("select.prompt"))
  resources = data[options.resources] || data
  resources = [] unless _.isArray(resources)

  for resource in resources
    value = getValue(options, resource)
    name  = getName(options, resource)
    target.append newOption(value, name)

newOption = (value, name) ->
  $("<option />").val(value).text(name)

getValue = (options, resource) ->
  data = resource

  for value in options.value.split(".")
    data = data[value]
  data

getName = (options, resource) ->
  data = resource

  for name in options.name.split(".")
    data = data[name]
  data

resetDependentLists = (options) ->
  current = options.select
  run     = true

  current.data("target", options.target) unless current.data("target")?

  while run
    current = resetTargetSelect(current)
    run     = false unless current?

resetTargetSelect = (current) ->
  target = current.data("target")
  target.empty() if target?
  target

isValidUrl = (url) ->
  return false if _.isEmpty url
  /(\/\/|\/$)/.test(url) is false

findTarget = (options) ->
  if _.isString(options.target)
    options.target = @$(options.target)
  options
