Modules.FillSelect =

  # Callbacks
  # ==========================================================
  #beforeInitialize: ->

  #afterInitialize: ->

  #beforeRemove: ->

  instanceMethods:

    fill_select: (options, reset = true) ->
      return if !options.url or !options.target

      findTarget.call(this, options)
      setDataTargetToSelect(options.select, options.target)
      resetDependentLists(options) if reset

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
    target.append(newOption(value, name))

  setSelectedOption(options) if options.model?

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

setDataTargetToSelect = (select, target) ->
  select.data("target", target) unless select.data("target")?

resetDependentLists = (options) ->
  current = options.select
  run     = true

  while run
    current = resetTargetSelect(current, options.model)
    run     = false unless current?

resetTargetSelect = (current, model) ->
  target = current.data("target")

  if target?
    resetTargetModel(target, model) if model?
    target.empty()

  target

isValidUrl = (url) ->
  return false if _.isEmpty url
  /(\/\/|\/$)/.test(url) is false

findTarget = (options) ->
  if _.isString(options.target)
    options.target = @$(options.target)
  options

resetTargetModel = (target, model) ->
  nestedModel   = getNestedModel(target, model)
  attributeName = getNestedAttributeName(target, model)

  attrs  = {}
  attrs[attributeName] = ""
  nestedModel.set(attrs, {silent: true})

setSelectedOption = (options) ->
  nestedModel   = getNestedModel(options.target, options.model)
  attributeName = getNestedAttributeName(options.target, options.model)

  value  = nestedModel.get(attributeName)
  option = options.target.find("option[value=\"#{value}\"]")
  option.attr("selected", "selected")

getNestedAttributeName = (target, model) ->
  selectName  = target.attr("name").replace("[]", "")
  nestedNames = selectName.split("[")
  nestedNames[nestedNames.length - 1].replace("]", "")

getNestedModel = (target, model) ->
  selectName   = target.attr("name")
  nestedNames  = selectName.split("[")
  nestedObject = null

  for nestedName in nestedNames
    nestedName   = nestedName.replace("]", "")
    nestedObject ||= model

    if (/^.+_attributes$/.test(nestedName))
      nestedName   = nestedName.replace("_attributes", "")
      nestedObject = nestedObject[nestedName]

    else if (/^backboneCid_.+$/.test(nestedName))
      nestedName   = nestedName.replace("backboneCid_", "")
      nestedObject = nestedObject.getByCid(nestedName)

  nestedObject
