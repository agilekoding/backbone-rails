Modules.Inheritance =

  include: (obj) ->
    inheritanceKeywords = ['included', 'beforeInitialize', 'afterInitialize', 'beforeRemove']

    classMethods = obj.classMethods || {}
    classMethods = classMethods() if _.isFunction classMethods

    for key, value of classMethods when key not in inheritanceKeywords
      @[key] = value

    instanceMethods = obj.instanceMethods || {}
    instanceMethods = instanceMethods() if _.isFunction instanceMethods

    for key, value of instanceMethods when key not in inheritanceKeywords
      # Assign properties to the prototype
      @::[key] = value

    obj.included?.apply(@)

    if obj.beforeInitialize?
      @::_beforeInitialize ||= []
      @::_beforeInitialize.push obj.beforeInitialize

    if obj.afterInitialize?
      @::_afterInitialize  ||= []
      @::_afterInitialize.push obj.afterInitialize

    if obj.beforeRemove?
      @::_beforeRemove     ||= []
      @::_beforeRemove.push obj.beforeRemove

    this
