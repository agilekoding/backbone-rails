Modules.ModalForm = (options = {}) ->

  # Callbacks
  # ==========================================================
  beforeInitialize: ->
    addDataToggleAttribute.call(this)

  #afterInitialize: ->

  #beforeRemove: ->

  instanceMethods: ->
    modalFormOptions: options

    hideModalForm: ->
      $("#modal_form_container").modal("hide")


  # Class Methods
  # ================================================================

  #classMethods:

    #class_method: ->


# Private Methods
# ================================================================
addDataToggleAttribute = ->
  _this = this

  for key, value of @modalFormOptions
    $target = $("#modal_form_container")
    success = _this[value["success"]]
    klass   = value["link"]
    modals  = $target.data("modals") || []

    unless _.include(modals, klass)
      modals.push(klass)
      $target.data("modals", modals)

      bindShowCallback.call(this, $target, value["view"], klass, success)
      bindHiddenCallback.call(this, $target, klass)
      bindClickEvent.call(this, $target, klass)

bindClickEvent = (target, klass) ->
  $("body").on "click.my_modal", klass, (e) ->
    e.preventDefault()
    $this   = $(this)
    option  = if target.data('modal') then 'toggle' else {}

    target.data("current_class", klass)
    target.data("modal_data", $this.data())
    target.modal(option)

bindShowCallback = (target, view, klass, callback) ->
  showFunction = =>
    if target.data("current_class") is klass
      callback = _.bind(callback, this) if callback?
      options  = _.extend
        modal_success: callback
        target.data("modal_data")

      @modal_form_view = new view(options)
      $("#modal_form_container .modal-body").html(@modal_form_view.render().el)

  target.on("show", showFunction)

bindHiddenCallback = (target, klass) ->
  hiddenFunction = =>
    if target.data("current_class") is klass
      @modal_form_view.remove()
      @modal_form_view = null

  target.on("hidden", hiddenFunction)
