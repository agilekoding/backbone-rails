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
  _this   = this

  for key, value of @modalFormOptions
    $target = $("#modal_form_container")
    success = _this[value["success"]]

    bindShowCallback.call(this, $target, value["view"], value["link"], success)
    bindHiddenCallback.call(this, $target, value["link"])
    bindClickEvent.call(this, $target, value["link"])

bindClickEvent = (target, klass) ->
  $("body").on "click", klass, (e) ->
    e.preventDefault()
    $this   = $(this)
    option  = if target.data('modal') then 'toggle' else {}

    target.data "current_class", klass
    target.data "modal_data", $this.data()
    target.modal(option)

bindShowCallback = (target, view, klass, callback) ->
  showFunction = =>
    if target.data("current_class") is klass
      options = _.extend
        modal_success: _.bind(callback, this)
        target.data("modal_data")

      @modal_form_view = new view(options)
      $("#modal_form_container .modal-body").html @modal_form_view.render().el

  target.on "show", showFunction

bindHiddenCallback = (target, klass) ->
  hiddenFunction = =>
    if target.data("current_class") is klass
      @modal_form_view.remove()
      @modal_form_view = null

  target.on "hidden", hiddenFunction
