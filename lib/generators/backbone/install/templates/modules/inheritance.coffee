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

    @::_afterInitialize  ||= []
    @::_beforeInitialize ||= []
    @::_beforeRemove     ||= []

    @::_beforeInitialize.push obj.beforeInitialize if obj.beforeInitialize?
    @::_afterInitialize.push obj.afterInitialize   if obj.afterInitialize?
    @::_beforeRemove.push obj.beforeRemove         if obj.beforeRemove?

    this
